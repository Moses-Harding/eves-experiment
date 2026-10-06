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
