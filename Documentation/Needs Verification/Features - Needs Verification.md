# Features - Needs Verification

Implemented and deployed, awaiting confirmation on real levels.

## FEAT-001 — Uncover hidden colours when no pour is safe

**Status:** Needs Verification (shipped 2026-10-05, build `b8e44ce`)

When no pour stays solvable in any remaining arrangement of the hidden layers,
the guide no longer stops at once. It plans towards the reachable position with
the most hidden layers on top, asks for each one as it appears, and replans; a
safe route may come back. Only when nothing more can be uncovered does it say
"Time to restart". Details in `Architecture/Solver and walkthrough.md`.

In simulation this triggers rarely: most dead ends are total deadlocks with no
pour left. Exploring earlier, whenever the planner has to gamble, took more
attempts to solve, so it only replaces the stop.

**To verify:** when a level runs out of safe pours with `?` layers left, the
pours are explained as uncovering colours, and the end screen reads "Time to
restart".

## FEAT-002 — Copy debug info

**Status:** Needs Verification (shipped 2026-10-06, build `26d01af`)

A link under the walkthrough copies a JSON report: build, browser, language, an
event log (start, pours, reveals, Back, every plan with its duration and flags)
and the current position. Paste it into a conversation to report a problem.

**To verify:** click it mid-walkthrough and paste; the report names the build
and lists the pours made.

## FEAT-003 — Copy a link to the solution

**Status:** Needs Verification (shipped 2026-10-06, build `37eb460`)

"Copy link" in the walkthrough copies `<page>?solve#<board>` for the level as
this attempt started. Opening it goes straight into the walkthrough.

**To verify:** copy a link, open it in a private window, and check it lands in
the walkthrough on the same board.
