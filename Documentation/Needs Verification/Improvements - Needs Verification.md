# Improvements - Needs Verification

## IMP-001 — Pour arrow: yellow-to-blue gradient, larger head

**Status:** Needs Verification (shipped 2026-10-06, build `37eb460`)

The line runs from yellow at the source tube to blue at the target, and the head
is 18px instead of 10px, filled blue.

## IMP-002 — Spinner while working

**Status:** Needs Verification (shipped 2026-10-06, build `37eb460`)

A spinning ring beside "Working out the next pours…" and "Reading the tubes…".
It fades in after 0.3s and keeps turning while the page is blocked.

**To verify:** on a large board, the ring turns rather than freezing while the
guide plans.

## IMP-003 — Tan replaces grey

**Status:** Needs Verification (2026-10-27)

The game's light brown / tan (measured `199,134,107` on level 10) read as brown.
Tan now takes grey's place in the palette (index 15, `#C7866B`, French "marron
clair") and has its own measured reference in the screenshot reader. Boards saved
with grey now show tan in that spot.

**To verify:** load the level 10 screenshot. Tubes 1, 5, 6 (top), and 7 read tan;
tube 6's third layer and tube 12 stay brown; no "Brown shows up 6 times" warning.
