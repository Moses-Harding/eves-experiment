# Completed Bugs

Fixed and verified. Patterns worth carrying forward are in
`Documentation/Bugs/Lessons Learned.md`; how the reader works now is in
`Documentation/Architecture/Screenshot reader.md`.

All of the below were found and fixed on 2026-09-29 and 2026-09-30. None had
been logged in `Bugs.md` beforehand — they surfaced while the screenshot reader
was being used on real levels.

## BUG-001 — Every colour outside the ten references read as red

`palLab` was built from `PALETTE[i][1]`, the French colour name, rather than
`[2]`, the hex. `hexRgb("rouge")` produced `NaN`, so every Lab distance was
`NaN`, the sort did nothing, and the first palette entry was returned
unconditionally. Violet, yellow, lime, teal, navy, grey, white and black were all
affected. The giveaway was the palette's own violet failing to match itself.

**Fix:** read `[2]`. All 18 palette colours now identify as themselves, verified
by a round-trip test.

## BUG-002 — Dragged colours had no fill

`PALETTE[DR.key][1]` in the drag ghost: the same mistake as BUG-001, in
unrelated code.

**Fix:** read `[2]`.

## BUG-003 — Three-row boards lost their top row

The lip scan covered only 22% to 85% of the image height. A three-row board
starts higher than that, so its first row was never detected. The crop existed to
hide the game's interface.

**Fix:** scan nearly the whole image and reject the interface structurally
instead — by lip width, row shape and grid fit.

## BUG-004 — Vertically aligned rows collapsed into one

Duplicate suppression discarded any lip within 4.2 tube-widths below an
overlapping one, to stop a tube's own lower edge registering again. A row's pitch
is a tube's height plus a small gap, so the rule also swallowed the row directly
beneath whenever rows lined up: six and six read as six, while six and five read
correctly only because a shorter row is centred and therefore offset.

**Fix:** distinguish the two by what sits immediately above the run — background
means a gap between rows, anything else means the same tube.

## BUG-005 — The game's interface read as tubes

Once the scan covered the whole image, the header badge and the button bar were
tube-width and became phantom tubes: a 13-tube board read as 15, one phantom
before the board and one after.

**Fix:** keep only the run of rows with consistent pitch, and drop rows whose
horizontal spacing disagrees with the board's columns.

## BUG-006 — Raising the row count added one tube, not a row

Asking for N rows took the block of N adjacent rows with the most tubes. A
one-element interface row scores the same as a real final row of one tube, so a
badge above the board could win: the right tube count, built from the wrong rows.

**Fix:** choose by how evenly spaced a block is, with tube count only as a
tie-break, and require every row but the last to be full.

## BUG-007 — Dropping a colour on an empty layer filled the wrong one

A drop onto an empty layer ran to the tube's lowest empty layer, so the first and
fourth layers of a tube could not be filled without filling the two between.

**Fix:** paint the layer under the pointer. A drop that misses the layers still
falls back to the lowest empty one.

## BUG-008 — The row stepper oscillated and discarded a correct board

The stepper displayed the row count found rather than the one requested, so a
request for four that could not be met snapped the display back to two and the
next press asked for three. Worse, the failed request replaced a correct 13-tube
board with the automatic 12-tube reading.

**Fix:** the number is a request and always moves; a request that cannot be met
leaves the board untouched and says so.

## BUG-009 — Pale liquids read as empty glass

Anything below 0.42 saturation was not a colour. The game's pale pink measures
0.314, so a tube of it read as empty.

**Fix:** allow a lower saturation when the layer is clearly bright. Glass and
hidden panels are dark, so brightness separates them.

## BUG-010 — Liquid floating above a gap

The layer height was fitted per row. A row holding one full tube offers a single
boundary, which fits four layers of 31.9px and three of 42.6px equally well; the
tie-break chose three by 0.2px, the fourth layer was sampled below the liquid and
came out empty, and the board became one no game can produce.

**Fix:** fit one height from the boundaries of all rows together.

## BUG-011 — A pale tube's false rims hid the rest of the board

A washed-out liquid passes the same bright-and-unsaturated test as the glass, so
one tube emitted extra lips. They landed between the real first and second rows,
and because only adjacent rows were considered together, they walled the real
rows off: the 14-tube board read as 8.

**Fix:** fit a row grid rather than taking adjacent rows, so rows sitting between
real ones are stepped over. Group rows with a tolerance that scales with tube
width, and keep only the highest of overlapping lips within a row.

## BUG-012 — Switching language would have emptied the colour menu

The contextual swatches carried `data-i` for the palette index, and `applyLang()`
sets `textContent` on every `[data-i]` element.

**Fix:** renamed to `data-pi`. Caught by a check before it ever ran.
