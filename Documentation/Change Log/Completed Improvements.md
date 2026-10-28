# Completed Improvements

Improvements (IMP-#) that were implemented and confirmed on a real level.

## IMP-003 — Tan replaces grey

**Completed:** 2026-10-27

The game's light brown / tan (measured `199,134,107` on level 10) read as brown.
Tan now takes grey's place in the palette (index 15, `#C7866B`, French "marron
clair") and has its own measured reference in the screenshot reader. Boards saved
with grey now show tan in that spot.

**To verify:** load the level 10 screenshot. Tubes 1, 5, 6 (top), and 7 read tan;
tube 6's third layer and tube 12 stay brown; no "Brown shows up 6 times" warning.

## IMP-004 — Keep looking runs by itself

**Completed:** 2026-10-27

When planning ran out of time, the walkthrough stopped on "Still working this
one out" until Keep looking was tapped. It now carries on planning straight
away. The button only shows when an automatic replan also times out without
finding a single pour, so it can't loop.

**To verify:** on a large level (level 10 times out on its first plan), the
spinner carries on into the next pours without a tap.
