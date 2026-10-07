# Bugs - Needs Verification

Fixed, awaiting confirmation on a real level.

## BUG-013 — A whole row vanished when one of its tubes was missed

**Status:** Needs Verification (fixed 2026-10-06)

Level 6 (rows of 6, 6 and 1) read as 6 + 1. The gap probe, which tells a
tube's own lower edge from the next row's rim, compares single pixels against
the background beside the tube. The backdrop is a photograph; above the last
tube of row two it measured `4,10,13` against `8,23,37` beside it, beyond the
tolerance of 26, so a real tube was rejected. Row two then had five tubes, the
shape rule treated a short middle row as interface, and the grid fit stepped
over it to a 6 + 1 board with a doubled pitch.

**Fix:** in a row whose tubes sit on the fullest row's columns, an empty column
with a tube-width rim at the row's height gets that tube back before the grid is
fitted. Level 6 now reads 6 + 6 + 1; levels 5 and 8 are unchanged.

**To verify:** upload the level 6 screenshot and check for 13 tubes.

## BUG-014 — Purple read as blue

**Status:** Needs Verification (fixed 2026-10-06)

The game's purple (`135,48,205`) had no measured reference and matched blue.
It showed in level 6 (tubes 3, 6, 7) and had silently misread level 8 tube 10.

**Fix:** added purple as a reference, mapped to violet.

**To verify:** level 6 tubes 3, 6 and 7 show violet in their second layer.

## BUG-015 — "No safe pour" shown when the planner had only run out of time

**Status:** Needs Verification (fixed 2026-10-06)

Reported on level 6 after four pours. The position shown has 8 pours that keep
all 420 arrangements of the hidden layers solvable, and planned fresh it gives a
21-pour route in 1.4s. The stuck screen is shown both for a real dead end and
for a plan that hit its 20-second deadline (`seg.timedOut`), and by elimination
(safe pours exist, and the uncover-colours fallback would have found pours) the
deadline is the only path that could produce it. The exact cause of the slow
plan is unconfirmed: the starting board and earlier pours weren't available.

**Fix:** a timed-out plan now says "Still working this one out" and offers Keep
looking, which replans from the current position. "Copy debug info" now
records each plan's duration and whether it timed out, so the next report will
show which it was.

**To verify:** if the guide stops again, check which screen appears, and paste
the debug info.

## BUG-016 — "Copy debug info" showed above the board on desktop

**Status:** Needs Verification (fixed 2026-10-06)

At 900px and wider the walkthrough is a CSS grid that places each child
explicitly. The new link had no rule, so it was auto-placed into the first free
cell, above the board. Live from build `26d01af` to `37eb460`.

**Fix:** `#walk>.dbg{grid-column:2;grid-row:6}`, under the controls.

**To verify:** on a desktop browser, the link sits under Edit the board /
Copy link, not above the tubes.
