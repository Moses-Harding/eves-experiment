# Lessons Learned

Patterns worth carrying forward, drawn from bugs actually fixed. See
`Documentation/Change Log/Completed Bugs.md` for the bugs themselves.

## Test an image reader against real input, early

Three consecutive rounds of screenshot-reader fixes passed every generated test
board and failed on the real game. The generated boards encoded assumptions about
how the game draws itself, so they could only ever confirm those assumptions.
The three real causes — a pale liquid emitting false glass rims, an ambiguous
layer height in a row holding one full tube, and a saturation floor that read
pale pink as empty — were all invisible to a canvas drawing of an imagined game.

Once a real screenshot was on disk, all three were found and fixed in one pass by
instrumenting the actual pipeline and printing what each stage kept and dropped.

**Apply:** for anything parsing real-world input, get one real sample before
writing the second fix. Generated cases are for regressions, not diagnosis.

## A heterogeneous tuple invites indexing mistakes

`PALETTE` rows are `[english, french, hex]`. Two separate places read `[1]`, the
French name, where they wanted `[2]`, the hex:

- the colour fallback, where `hexRgb("rouge")` gave `NaN`, every Lab distance
  came out `NaN`, the sort did nothing, and **every colour outside the ten
  measured references read as red**;
- the drag ghost, which therefore had no fill at all.

Neither failed loudly. A `HEX(i)` helper already existed and was not used.

**Apply:** when a tuple's fields are different kinds of thing, access them
through named helpers. If a lookup can silently produce `NaN`, make it
self-identify — every palette colour now round-trips to itself in a test.

## Don't reuse an attribute the framework owns

Swatch buttons carried `data-i` for the palette index. `applyLang()` treats every
`[data-i]` element as translated text and sets its `textContent`, so switching
language with the menu open would have emptied every swatch. Renamed to
`data-pi`.

**Apply:** `data-i` is the translation hook. Pick another name.

## A status code is not evidence

Cloudflare Pages serves `index.html` for unknown paths, so `/anything` returns
**200**. A check that a file was not published has to compare the body or the
size, not the status. `/level.png` returning 200 with 81KB of HTML means the
screenshot was not uploaded; it would have been 3.2MB.

The mirror of this: `python3 -m http.server` lets the browser cache
`index.html`, so a plain reload can silently serve stale code. A test failed
against code that was definitely on disk. Hard-reload, or append `?v=N`.

## When a tie-break decides between physical interpretations, get more evidence

The layer height fit scored 4 layers of 31.9px against 3 of 42.6px and chose on a
0.2px difference in rounding error. Both fit the single boundary available in
that row; only one is a real board. Refining the tie-break would have been
guesswork. Pooling the boundaries from every row — all tubes in a game are the
same size — made the question unambiguous.

**Apply:** a tie-break separating two qualitatively different answers is a sign
the input is under-determined. Widen the evidence rather than sharpen the rule.

## State the constraint the domain already gives you

Several reader bugs dissolved once the board's own rules were written down:
tubes fill left to right and top to bottom, so every row is full except the last;
two rows cannot be closer than one tube's height; every tube is the same size.
Each replaced a tuned threshold with something that cannot drift.

**Apply:** before tuning a constant, ask what the domain guarantees.

## Widening a filter moves the problem rather than removing it

Cropping the lip scan to the middle of the image hid the game's interface and
also hid the top row of a three-row board. Widening the scan fixed the row and
let the interface in, which produced phantom tubes. The real fix was structural —
grid fit, modal width, row shape — none of which depends on where in the frame
the board sits.

**Apply:** when a positional filter is doing two jobs, replace it rather than
retune it.

## A hard filter in front of a global rule turns one miss into a lost row

Row loss has come back five times (BUG-003, BUG-004, BUG-006, BUG-011,
BUG-013), each from a different trigger. The shape is always the same: an early
stage throws away a candidate for good, using a local, single-pixel test, and a
later rule that reasons about the whole board — rows must be full, rows sit on a
grid — turns that one miss into a missing row. The board that comes out is
still valid, so nothing flags it.

**Apply:** when an early test rejects something, keep it as a candidate that the
global stage can recover, rather than deleting it. Let the board's own structure
— columns, pitch, full rows — confirm or veto the local guess. And when the
result is a valid-looking board that differs from the evidence, such as a row
of rims that went unused, say so rather than choosing silently.

## Don't let "I ran out of time" share a screen with "there is no answer"

The planner stopped for two different reasons, a real dead end and a 20-second
deadline, and both showed "No safe pour, restart the level". So a timeout read
as a verdict on the puzzle, and the user was told to restart a level that had
eight safe pours (BUG-015). Separating them was trivial; noticing needed the
position rebuilt and checked by hand.

**Apply:** a limit hit (time, nodes, retries) is "unknown", never "no". Give it
its own message and a way to carry on. And record enough to tell them apart
afterwards: the debug log now stores every plan's duration and `timedOut` flag.

## Ship the bug-report button before the next bug

The "No safe pour" report (BUG-015) could not be reproduced exactly: the
starting board and earlier pours lived only in the user's tab, so the cause was
reached by elimination and the slow plan behind it is still open (BUG-017). "Copy debug info"
now captures them. When a tool's state is hard to reconstruct, make exporting it
a single click.
