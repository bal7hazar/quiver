//! Association pages: the live quests using a task, 7 per page (ARC-01 §3.2, §3.5).
//!
//! Pages are contiguous: every page before the last non-full page is full. `define` keeps it by
//! pushing on the first non-full page; `retire` by moving the last id of the last non-empty page
//! (`page_pop`) into the hole (`page_position`, `page_set`). Every function is unrolled over the
//! 7 slots: no loop.

use crate::constants::QUESTS_PER_PAGE;
use crate::errors;
use super::definition::conditions_span;
use super::types::{QuestConditions, QuestIdPage};

/// The panic of a position outside `0..len`, as the corelib's for a span. Not an error of the
/// API: the component never makes such a call.
const INDEX_OUT_OF_BOUNDS: felt252 = 'Index out of bounds';

/// Appends `quest_id`. Panics `'Quest: task full'` when the page holds `QUESTS_PER_PAGE` ids.
pub fn page_push(page: QuestIdPage, quest_id: u32) -> QuestIdPage {
    assert(page.len < QUESTS_PER_PAGE, errors::TASK_FULL);
    QuestIdPage { len: page.len + 1, ids: ids_set(page.ids, page.len, quest_id) }
}

/// The first `len` ids.
pub fn page_span(page: @QuestIdPage) -> Span<u32> {
    conditions_span(page.ids, *page.len)
}

/// The position of `quest_id` among the first `len` ids, if any.
pub fn page_position(page: @QuestIdPage, quest_id: u32) -> Option<u8> {
    let QuestIdPage { len, ids } = *page;
    if len > 0 && ids.q0 == quest_id {
        return Some(0);
    }
    if len > 1 && ids.q1 == quest_id {
        return Some(1);
    }
    if len > 2 && ids.q2 == quest_id {
        return Some(2);
    }
    if len > 3 && ids.q3 == quest_id {
        return Some(3);
    }
    if len > 4 && ids.q4 == quest_id {
        return Some(4);
    }
    if len > 5 && ids.q5 == quest_id {
        return Some(5);
    }
    if len > 6 && ids.q6 == quest_id {
        return Some(6);
    }
    None
}

/// Writes `quest_id` at `position`. Panics `'Index out of bounds'` unless `position < len`.
pub fn page_set(page: QuestIdPage, position: u8, quest_id: u32) -> QuestIdPage {
    assert(position < page.len, INDEX_OUT_OF_BOUNDS);
    QuestIdPage { len: page.len, ids: ids_set(page.ids, position, quest_id) }
}

/// Removes the last id and returns it; its slot is zeroed. Panics `'Index out of bounds'` when
/// the page is empty.
pub fn page_pop(page: QuestIdPage) -> (QuestIdPage, u32) {
    assert(page.len != 0, INDEX_OUT_OF_BOUNDS);
    let last = page.len - 1;
    let ids = page.ids;
    let quest_id = match last {
        0 => ids.q0,
        1 => ids.q1,
        2 => ids.q2,
        3 => ids.q3,
        4 => ids.q4,
        5 => ids.q5,
        _ => ids.q6,
    };
    (QuestIdPage { len: last, ids: ids_set(ids, last, 0) }, quest_id)
}

/// `ids` with `id` at `position` (0..7).
fn ids_set(ids: QuestConditions, position: u8, id: u32) -> QuestConditions {
    match position {
        0 => QuestConditions { q0: id, ..ids },
        1 => QuestConditions { q1: id, ..ids },
        2 => QuestConditions { q2: id, ..ids },
        3 => QuestConditions { q3: id, ..ids },
        4 => QuestConditions { q4: id, ..ids },
        5 => QuestConditions { q5: id, ..ids },
        6 => QuestConditions { q6: id, ..ids },
        _ => core::panic_with_felt252(INDEX_OUT_OF_BOUNDS),
    }
}
