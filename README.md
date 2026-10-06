# Eve's Experiment

A step-by-step solver for water-sort tube puzzles — the kind where you pour colored
liquid between tubes until each one holds a single color, and some layers start out
hidden.

**[Open it →](https://eves-experiment.pages.dev)**

Set up your level, then follow one pour at a time. When a hidden layer comes to the
top and shows its color, you tell the solver what it is and the route re-plans from
there.

## What it does

- **Reads a screenshot.** Point it at a screenshot of your level and it fills in the
  tubes for you, flagging any layers it wasn't confident about so you can correct them.
- **Or paint by hand.** Drag colors from the palette onto tubes, or tap to fill. Mark
  hidden layers with `?`.
- **Checks your board before solving.** Catches gaps, a known color sitting under a
  hidden one, a color used more than four times, a layer count that doesn't divide into
  complete colors, and boards that simply can't be solved as painted.
- **Plans around what it can't see.** Rather than guessing at hidden layers, it only
  makes pours that keep the puzzle solvable under *every* still-possible arrangement of
  them. If no such pour exists, it says so instead of walking you into a dead end.
- **Adapts as layers are revealed.** Each reveal narrows the possibilities and the rest
  of the route is replanned.
- **Shareable links.** The board is encoded in the URL. **Copy link** in the walkthrough
  shares the level as it started, and the link opens straight into the solution.
- **English and French**, light and dark themes, and it remembers your last board.

Supports 2–24 tubes, four layers per tube, and an 18-color palette.

## Running it

It's one static HTML file with no build step and no dependencies:

```
git clone https://github.com/Moses-Harding/eves-experiment.git
cd eves-experiment
python3 -m http.server 8000
```

Then open `http://localhost:8000`.

Opening `index.html` directly from disk mostly works, but the copy-link button needs a
secure context (`https://` or `localhost`), so serve it rather than double-clicking it.

## Privacy

Everything runs in your browser. Screenshots are parsed locally and never uploaded —
the page makes no network requests of its own. The only external resource it loads is
the webfont stylesheet from Google Fonts. Your last board is kept in `localStorage`.

## License

MIT — see [LICENSE](LICENSE).
