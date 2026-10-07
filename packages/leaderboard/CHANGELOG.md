# Changelog

All notable changes to `quiver_leaderboard` are recorded here, following
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/). Changes to results and storage layout are
named.

## [Unreleased]

### Added

- First version (ARC-05a), written from Paved's specification: the `LeaderboardStorage` storage
  node, `submit`, `ranked` and `top` as trait methods on its storage path, top 3, 4 slots per
  tournament (one word of three scores, one player slot per rank), no entry point, no event.
  `LeaderboardSubmitted`, an event type a consumer may emit itself.
