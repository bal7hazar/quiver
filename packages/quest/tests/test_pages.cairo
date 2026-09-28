use quiver_quest::logic::{
    MAX_PAGES, QUESTS_PER_PAGE, QuestIdPage, page_pop, page_position, page_push, page_set, page_span,
};
use super::helpers::{ids, no_ids, page};

fn empty() -> QuestIdPage {
    page(0, no_ids())
}

fn full(first: u32) -> QuestIdPage {
    page(7, ids(first, first + 1, first + 2, first + 3, first + 4, first + 5, first + 6))
}

// page_push, page_span

#[test]
#[available_gas(l2_gas: 99999999)]
fn page_push_appends_until_full() {
    let mut p = empty();
    let mut id: u32 = 1;
    while id <= QUESTS_PER_PAGE.into() {
        p = page_push(p, id * 10);
        id += 1;
    }
    assert!(p == page(7, ids(10, 20, 30, 40, 50, 60, 70)));
    assert!(page_span(@p) == array![10, 20, 30, 40, 50, 60, 70].span());
}

#[test]
#[available_gas(l2_gas: 99999999)]
fn page_span_has_len_entries() {
    assert!(page_span(@empty()) == array![].span());
    assert!(page_span(@page_push(empty(), 5)) == array![5].span());
    assert!(page_span(@page(3, ids(1, 2, 3, 0, 0, 0, 0))) == array![1, 2, 3].span());
}

#[test]
#[should_panic(expected: 'Quest: task full')]
#[available_gas(l2_gas: 99999999)]
fn page_push_full_panics() {
    page_push(full(1), 99);
}

// page_position, page_set, page_pop

#[test]
#[available_gas(l2_gas: 99999999)]
fn page_position_among_len_ids() {
    let p = full(1);
    assert!(page_position(@p, 1) == Some(0));
    assert!(page_position(@p, 4) == Some(3));
    assert!(page_position(@p, 7) == Some(6));
    assert!(page_position(@p, 8) == None);
    let partial = page(2, ids(1, 2, 0, 0, 0, 0, 0));
    assert!(page_position(@partial, 2) == Some(1));
    // the zero of an unused slot is never a position
    assert!(page_position(@partial, 0) == None);
}

#[test]
#[available_gas(l2_gas: 99999999)]
fn page_set_replaces_one_id() {
    let p = full(1);
    assert!(page_set(p, 0, 50) == page(7, ids(50, 2, 3, 4, 5, 6, 7)));
    assert!(page_set(p, 6, 50) == page(7, ids(1, 2, 3, 4, 5, 6, 50)));
    let partial = page(2, ids(1, 2, 0, 0, 0, 0, 0));
    assert!(page_set(partial, 1, 9) == page(2, ids(1, 9, 0, 0, 0, 0, 0)));
}

#[test]
#[should_panic(expected: 'Index out of bounds')]
#[available_gas(l2_gas: 99999999)]
fn page_set_beyond_len_panics() {
    page_set(page(2, ids(1, 2, 0, 0, 0, 0, 0)), 2, 9);
}

#[test]
#[available_gas(l2_gas: 99999999)]
fn page_pop_removes_the_last_id() {
    let (p, id) = page_pop(full(1));
    assert!(id == 7);
    assert!(p == page(6, ids(1, 2, 3, 4, 5, 6, 0)));
    let (p, id) = page_pop(page(1, ids(9, 0, 0, 0, 0, 0, 0)));
    assert!(id == 9);
    assert!(p == empty());
}

#[test]
#[should_panic(expected: 'Index out of bounds')]
#[available_gas(l2_gas: 99999999)]
fn page_pop_empty_panics() {
    page_pop(empty());
}

// The retirement algorithm of ARC-01 §3.5 on pages held in memory: the component does the same
// with storage reads and writes. Pages stay contiguous.

/// Pages of a task holding `n` ids, `1..=n`, pushed as `define` does (first non-full page).
fn pages_with(n: u32) -> Array<QuestIdPage> {
    let mut out = array![];
    let mut id: u32 = 1;
    let mut current = empty();
    while id <= n {
        current = page_push(current, id);
        if current.len == QUESTS_PER_PAGE {
            out.append(current);
            current = empty();
        }
        id += 1;
    }
    while out.len() < MAX_PAGES.into() {
        out.append(current);
        current = empty();
    }
    out
}

/// Appends `quest_id` to the first non-full page, as `define` does.
fn pages_push(pages: Span<QuestIdPage>, quest_id: u32) -> Array<QuestIdPage> {
    let mut out = array![];
    let mut done = false;
    for p in pages {
        if !done && *p.len < QUESTS_PER_PAGE {
            out.append(page_push(*p, quest_id));
            done = true;
        } else {
            out.append(*p);
        }
    }
    assert!(done, "task full");
    out
}

/// Removes `quest_id` as `retire` does: fill its hole with the last id of the last non-empty page.
fn pages_remove(pages: Span<QuestIdPage>, quest_id: u32) -> Array<QuestIdPage> {
    let mut hole_page: u32 = MAX_PAGES.into();
    let mut hole: u8 = 0;
    let mut last: u32 = 0;
    let mut i: u32 = 0;
    for p in pages {
        if let Some(position) = page_position(p, quest_id) {
            hole_page = i;
            hole = position;
        }
        if *p.len > 0 {
            last = i;
        }
        i += 1;
    }
    assert!(hole_page < MAX_PAGES.into(), "not on the pages");
    let (last_page, moved) = page_pop(*pages[last]);
    let mut out = array![];
    let mut i: u32 = 0;
    for p in pages {
        let mut next = *p;
        if i == last {
            next = last_page;
        }
        if i == hole_page && moved != quest_id {
            next = page_set(next, hole, moved);
        }
        out.append(next);
        i += 1;
    }
    out
}

/// Every page before the last non-full page is full; nothing after a non-full page.
fn assert_contiguous(pages: Span<QuestIdPage>) {
    let mut seen_partial = false;
    for p in pages {
        if seen_partial {
            assert!(*p.len == 0, "page after a non-full page");
        }
        if *p.len < QUESTS_PER_PAGE {
            seen_partial = true;
        }
    }
}

fn all_ids(pages: Span<QuestIdPage>) -> Array<u32> {
    let mut out = array![];
    for p in pages {
        for id in page_span(p) {
            out.append(*id);
        }
    }
    out
}

#[test]
#[available_gas(l2_gas: 99999999)]
fn pages_removal_keeps_pages_contiguous() {
    // 17 ids: pages of 7, 7, 3, 0. Remove from the first page, the last page, the last id.
    let pages = pages_with(17);
    assert_contiguous(pages.span());
    let pages = pages_remove(pages.span(), 3);
    assert_contiguous(pages.span());
    assert!(
        all_ids(pages.span()) == array![1, 2, 17, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
    );
    let pages = pages_remove(pages.span(), 16);
    assert_contiguous(pages.span());
    let pages = pages_remove(pages.span(), 8);
    assert_contiguous(pages.span());
    assert!(all_ids(pages.span()) == array![1, 2, 17, 4, 5, 6, 7, 15, 9, 10, 11, 12, 13, 14]);
    // 14 ids left: two full pages; removing empties no page in between
    let pages = pages_remove(pages.span(), 1);
    assert_contiguous(pages.span());
    assert!(*pages[1].len == 6 && *pages[2].len == 0);
}

#[test]
#[available_gas(l2_gas: 99999999)]
fn quest_retire_frees_slot_pages() {
    // 28 live quests on a task; quest 3 retired; one more fits and 3 is gone
    let pages = pages_with(28);
    assert!(*pages[3].len == QUESTS_PER_PAGE);
    let pages = pages_remove(pages.span(), 3);
    assert_contiguous(pages.span());
    let pages = pages_push(pages.span(), 29);
    assert_contiguous(pages.span());
    let listed = all_ids(pages.span());
    assert!(listed.len() == 28);
    let mut found_3 = false;
    let mut found_29 = false;
    for id in listed {
        if id == 3 {
            found_3 = true;
        }
        if id == 29 {
            found_29 = true;
        }
    }
    assert!(!found_3 && found_29);
}

#[test]
#[available_gas(l2_gas: 99999999)]
fn pages_removal_of_the_only_id() {
    let pages = pages_remove(pages_with(1).span(), 1);
    assert_contiguous(pages.span());
    assert!(all_ids(pages.span()) == array![]);
    assert!(*pages[0] == empty());
}
