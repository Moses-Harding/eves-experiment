# Screenshot reader

`readScreenshot(img, cap, want)` in `index.html` turns a screenshot of the game
into a board. Everything here was derived from real screenshots; most of the
rules exist because a simpler version failed on one. **Read this before
changing any threshold** — several look arbitrary and are not.

`want` is an optional row count supplied by the user through the "Rows of tubes
in your game" stepper. Zero or undefined means work it out automatically.

## The pipeline

1. **Scale** the image to 390px wide. Every constant below is in that space, so
   they hold regardless of the phone the screenshot came from.
2. **Find lips.** Scan almost the whole height for short, bright, weakly
   saturated horizontal runs — the glass rim at the top of a tube. Runs are kept
   when between 7% and 17% of the width.
3. **Discard duplicates.** The same rim is found on many scan lines, and a run
   below an existing tube is either that tube's own lower edge or the next row's
   rim.
4. **Keep tube-width runs.** Anything away from the board's median lip width is
   interface, not a tube.
5. **Group into rows** by y, then **fit a row grid** to decide which rows are
   the board.
6. **Fit one layer height** across all rows together.
7. **Classify each layer** as a colour, a hidden layer, or empty.

## Why each rule is there

### The scan covers nearly the whole image

It used to run from 22% to 85% of the height. A three-row board is tall enough
that its top row sits above that, so the row vanished silently. The crop existed
to hide the game's own interface; that job now belongs to the width filter and
the grid fit, which do not care where in the frame the board sits.

### Telling a tube's bottom edge from the next row's rim

Distance alone cannot do it: a row's pitch is a tube's height plus a small gap,
so a window wide enough to cover a tube also swallows the row beneath. Boards
whose rows line up vertically lost every row but the first — six and six read as
six, while six and five read correctly, because a shorter second row is centred
and therefore offset.

Instead, look at what is immediately **above** the run. Background means a gap
between rows; anything else means we are still inside a tube. The probe walks
upward rather than sampling one fixed height, so tightly packed rows still
register, and it compares against background sampled beside the tube at the same
height, which keeps a dark hidden layer from reading as background.

**The probe is not reliable on its own.** It compares single pixels, and the
game's backdrop is a photograph whose brightness changes by more than the
tolerance over a few pixels. On level 6 the background above the last tube of
row two measured `4,10,13` against `8,23,37` beside it, so a real tube was read
as the inside of the one above. See the next section for what catches that.

### A row on the board's columns gets its missing tubes back

After interface rows are dropped, any row whose tubes all sit on the fullest
row's columns, and which has at least half as many tubes, is checked column by
column. Where a column is empty and a tube-width rim was found at the row's
height in that column — typically one the gap probe rejected — it is restored.

Without this, one missed tube costs the whole row: the shape rule below reads a
short middle row as interface, and the grid fit then steps over it to another
board that looks valid. A 6 + 6 + 1 board read as 6 + 1, with nothing to say a
row had gone. Rims a pale liquid gives off sit at layer boundaries, not at a
row's rim height, and only ever in a column that already has its tube, so they
are not restored.

### Rows are chosen by fitting a grid, not by adjacency

A pitch is proposed from each pair of detected rows and rows are collected at
multiples of it. Rows that are not part of the board are stepped over.

This matters because **a pale liquid gives off lips of its own** — a washed-out
pink is bright and weakly saturated, which is exactly what the lip test looks
for. Those false rows land between real ones. While only neighbouring rows were
considered together, they walled the real rows off from each other and the board
could not be assembled at all.

Two further constraints:

- **Minimum pitch** of twice the tube width. Two rows of tubes cannot be closer
  than roughly one tube's height, so anything nearer is not a separate row.
- **Shape**: tubes fill left to right and top to bottom, so every row is full
  except possibly the last. A short row anywhere but the end is interface. This
  is what stops a one-element header badge standing in for a real final row of
  one tube — both give the same row count, so tube count alone cannot choose.

When a row count is given, a final row is allowed to sit off the pitch, because
a last row of one or two tubes often does.

### The layer height is fitted once, across all rows

Coloured runs end on layer boundaries, at `y0 + k*h`. Heights in a plausible
range are scored by how many run ends line up.

It used to be fitted per row, and a row holding a single full tube is ambiguous:
one boundary 128px below the lip fits **four layers of 31.9 or three of 42.6**
equally well. The tie-break on rounding error chose three by 0.2px, the fourth
layer was then sampled below the liquid and came out empty, and the board had
liquid floating above a gap — something no game can produce. Every tube in a
game is the same size, so pooling the boundaries from all rows lets the
well-evidenced rows settle the ambiguous one.

### What counts as liquid

`isColour(s, m)` accepts a layer when it is bright enough (`m >= 75`) and either
saturated (`s >= 0.42`) or clearly bright with some colour (`m >= 150 && s >=
0.18`).

The second clause exists for pale liquids. A flat 0.42 cut-off read the game's
pale pink — measured at saturation 0.314, max 223 — as empty glass. Glass and
hidden panels are dark (max around 57), so brightness is what actually separates
them, not saturation.

### Colours

Eleven reference colours measured from real screenshots are tried first. Anything
further than 18 in Lab falls back to the nearest of the full palette.

Purple (`135,48,205`) had no reference until level 6. It sat within 18 of the
measured blue and read as blue, flagged unsure but wrong, on every board it
appeared on, including level 8. Each new colour the game shows needs its own
measured reference; the palette fallback is only reached when nothing is close.

The fallback was broken from the start: it was built from `PALETTE[i][1]`, the
French colour name, rather than `[2]`, the hex. Every distance came out `NaN`,
the sort did nothing and the first entry was always returned, so **every colour
outside the ten references read as red**. Use the `HEX(i)` helper rather than
indexing the tuple by hand.

## Things that will bite

- **Palette indices are a storage format.** `encode()` writes
  `index.toString(36)` into the saved board and the URL hash. Adding a colour
  means appending it; inserting one renumbers the colours after it and repaints
  every board already saved in someone's browser. `SWATCHES` carries display
  order so a new colour can still appear next to its relatives — this is why
  light pink is stored at index 18 but shown beside pink.
- `_` and `x` are reserved in the encoding for empty and hidden. Indices stay
  clear of them up to 32.
- **The reader runs on the image element still on screen**, so changing the row
  count re-reads without another upload. It needs the object URL kept alive,
  which is why `showShot` holds it and only `hideShot` revokes it.

## Known limits

- An unaided read of a board whose last row sits well off the pitch comes out
  one row short. The row stepper corrects it in one tap.
- Empty tubes drawn in exactly the page background colour, with a bright bottom
  edge, can read as an extra row. Not observed in the real game.
- Pure white and grey layers are not detected: both fall under the saturation
  floor, and nothing distinguishes them from glass yet.

## Testing it

Two kinds, and the second is the one that matters:

- **Generated boards.** Drawn on a canvas and fed straight to
  `readScreenshot`. Cheap, and good for row geometry: row counts, aligned and
  offset rows, chrome above and below, pale liquids, tight and loose gaps.
- **Real screenshots.** Put one in the project root — `*.png` is git-ignored, and
  this repository is public — serve the folder, and read it with
  `new Image()` from `/yourfile.png`.

Headless Chrome runs the real reader without clicking through the page: serve a
folder holding a copy of `index.html` and the screenshot, and open a small page
that loads the copy in an iframe, calls
`frame.contentWindow.readScreenshot(img, 4, 0)` and writes the result into the
DOM. Then run `Google Chrome --headless=new --virtual-time-budget=15000
--dump-dom <url>`. Canvas scaling is the browser's own, so results match what a
user sees. Keep the harness out of the repository with the screenshots.

**Generated boards are not enough on their own.** Three separate rounds of
fixes passed every generated case and failed on the real game. Each real cause —
pale liquid emitting lips, the ambiguous single-tube row, the saturation floor —
was invisible to a canvas drawing of what the game was assumed to look like. Get
a real screenshot early.
