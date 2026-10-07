# Bugs

Active bugs being investigated or in progress.

## BUG-017 — Why the level 6 plan ran out of time

**Status:** Open, waiting for a debug report (logged 2026-10-06)

BUG-015 stopped a timeout from being presented as a dead end, but not the
timeout itself. On level 6, four pours in, the guide gave up at a position where
8 pours are safe in all 420 arrangements and a fresh plan takes 1.4s. By
elimination the 20-second deadline in `planFrom` was hit, which only the earlier
part of that plan (from the starting board, before those four pours) could
explain. The starting board wasn't captured.

**Next step:** when it happens again, use Copy debug info. Each `plan` event
records `ms` and `timedOut`, and `start` records the board, so the slow plan can
be replayed exactly.

**Suspects, unconfirmed:** `solvable()` gives up after 300k nodes per world, so a
plan that tests many hard or unsolvable arrangements can spend most of the 20s
proving dead ends; the deadline also covers the whole run of pours up to the
next reveal, not one pour.
