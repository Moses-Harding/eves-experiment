# Solver and walkthrough

How the guide decides each pour, and how the walkthrough presents it. All of it
is in `index.html`: the solver is `makeSolver` in the first `<script>` block, and
the walkthrough is the `// ---------------- walkthrough` section of the second.

## The board as the solver sees it

A tube is an array of codes, bottom to top. A known colour is `c<palette index>`
(`c12` is pink); a colour not visible anywhere at the start is `U1`, `U2`… until
the user names it; a hidden layer is `?<id>`. `check()` builds this from the
editor and also builds the **pool**: the colours the hidden layers must be,
which is everything not yet visible four times.

A **world** is one assignment of the pool to the hidden ids. Unseen colours are
interchangeable until revealed, so `possibleColors()` offers only the first
unnamed one when asking what a layer is.

## Planning a segment

`planSegment(state, revealed, visited, maxWorlds, deadline)` plans pours from
the current position until a hidden layer reaches the top of a tube, or the
puzzle is solved. That run of pours is a **segment**; the reveal ends it, the
user names the colour, and the next segment is planned with that knowledge.

1. Sample up to `maxWorlds` worlds consistent with what is revealed (all of them
   if there are few enough) and keep those still solvable.
   `worldBudget()` is 150 when the pool has at most 150 arrangements, else 80.
2. For each pour, count the worlds in which the result is still solvable.
   Skip pours that return to a visited position.
3. Take the pour that is safe in the most worlds, with ties broken by a three-pour
   lookahead `score()`. A pour safe in every world is safe outright; one safe
   in only some is a gamble.
4. If no pour is safe in any world, call `explore()` (below). If even that
   finds nothing, the segment is `stuck`.

`solvable()` is a full-information depth-first search. **Hitting its 300,000-node
limit counts as solvable** — fast, but optimistic.

The whole segment shares one `deadline`, set 20 seconds after `planFrom` starts.
Passing it ends the segment with `stuck` and `timedOut`.

## When nothing is safe: explore

Once no pour is safe, the attempt will end in a restart, and everything uncovered
before then will already be showing next time (`restartLevel()` fills found
colours into the starting board). So the attempt is spent on information.

`explore()` searches breadth-first (60,000 positions at most) for the reachable
position with the most hidden layers on top, treating them as unknown so nothing
pours onto or off them. Ties go to the shallowest, then the best `score()`. It
returns the pours up to the first layer uncovered; the usual question follows,
and the next segment is planned normally, so a safe route can come back.

`seg.explore` is the index of the first exploring pour in a segment. The
walkthrough uses it to explain those pours, and shows "Time to restart" rather
than "No safe pour" once exploring has run out.

Exploring earlier, whenever the planner has to gamble, was simulated and took
more attempts to solve. Gambling first is deliberate.

## The walkthrough's end states

| Node | Screen | Action offered |
|---|---|---|
| `done` | Solved | — |
| `timedOut` | Still working this one out | Keep looking: replan from here |
| `stuck`, after exploring | Time to restart | I restarted the level |
| `stuck` | No safe pour from here | I restarted the level |

A timeout is "unknown", not a dead end; see Lessons Learned.

## Keeping the page responsive

Planning and screenshot reading run on the main thread and block it.
`withWork()` sets `busy`, renders the waiting state, and waits **two animation
frames** before starting, so the waiting state is painted first. The spinner is
a CSS `transform` animation, which the compositor keeps running while the main
thread is blocked; it fades in after 0.3s so quick steps don't flash it.

## Links

The editor board is always in the address bar (`#<encoded board>`, written by
`saveEd()`), and in `localStorage`. `encode(cells)` writes the capacity, then one
character per layer (`_` empty, `x` hidden, the palette index in base 36).

**Copy link** gives `<page>?solve#<board>` for `P.start`, the board this attempt
began from. On load, `?solve` with a valid board starts the walkthrough at once,
and is removed from the address first so a reload or an edit doesn't restart it.

## Copy debug info

`logEv()` appends to `LOG`, which resets when Solve it is pressed and carries
across a restart. Events, with `t` in milliseconds from the first:

- `start` / `restart`: `board` (encoded), `pool` size, `unseen` count
- `pour`: `from`, `to` (1-based), `k` layers
- `reveal`: `tube`, `code`, `color`
- `back`
- `plan`: `ms`, `worlds`, `pours`, `done`, `stuck`, `timedOut`, `explore`, `askTube`

`debugText()` adds the build, browser, language and the current position:
encoded board, raw tubes, colour map, revealed layers, step, and the current
segment's pours and flags. `BUILD` is `'dev'` in the source; `deploy.sh` stamps
the commit hash into the uploaded copy.

To replay a report: start from the `start` board, and compare each `plan` event
with what `planSegment` gives for that position. Sampling uses `Math.random`, so
a large pool won't reproduce move for move; seed it in a test copy if that
matters.

## Testing

The solver can be cut out of the page and required from Node; see the solver
item in `Notes/Deferred.md`. For the real page, drive headless Chrome through
its DevTools protocol (`--remote-debugging-port`, then `Runtime.evaluate` with
`awaitPromise`). `--dump-dom` returns before a long plan finishes, so it can't be
used to wait for one. Keep these harnesses outside the repository.
