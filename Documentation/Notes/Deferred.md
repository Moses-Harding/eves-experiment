# Deferred

Items consciously set aside, with the reasoning, so they are not rediscovered
from scratch. Nothing here is a bug.

## Self-host the webfonts

`index.html` loads Bricolage Grotesque and Atkinson Hyperlegible from Google
Fonts. That stylesheet is the **only** external request the page makes, so every
visitor's IP reaches Google on load, and it is the single thing preventing the
page from being fully self-contained and offline-capable.

*Why deferred:* raised 2026-09-29 and declined for now — it is a privacy nicety,
not a defect, and the two files add weight to a currently single-file app.

*If picked up:* download both families, subset to the weights actually used
(Bricolage 500/700 variable, Atkinson 400/700), inline as base64 `@font-face` or
add as real files. Note that real font files would also need adding to the `cp`
line in `deploy.sh` — see `Documentation/Architecture/Hosting and deployment.md`.

## Extract the solver core so it can be tested from Node

The solver is `makeSolver` in `index.html` — the first `<script>` block — and it
ends with `if (typeof module !== 'undefined') module.exports = makeSolver;`. A
comment above it claims it "Works in Node (require)".

**That claim is not true as packaged.** The export sits inside a `<script>` tag
in an HTML document, so `require('./index.html')` cannot work. The export line
is harmless — the `typeof module` guard makes it inert in the browser — but it
advertises a capability that does not exist. A README section describing Node
usage was drafted and removed for this reason before the first commit.

*Why deferred:* fixing it properly means splitting the file, which gives up the
single-file property that makes the app trivial to host and share.

*If picked up:* move `makeSolver` to `solver.js`, have `index.html` load it,
add it to `deploy.sh`'s staged files, and then unit-test the solver directly —
`solvable()`, `planSegment()` and the hidden-layer `worlds()` enumeration are
the parts worth covering, especially the guarantee that a chosen pour keeps the
board solvable under every arrangement still consistent with what is revealed.
Either fix or delete the misleading comment at the same time.

## Full pseudonymous republish

Currently the live URL is name-free but the source repository is openly the
author's. Making the project genuinely unlinkable was considered and explicitly
not chosen on 2026-09-29.

*Why deferred:* "a neutral URL is enough" was the decision. The stronger version
costs real effort for a puzzle solver.

*If picked up:* see the "Identity surface" section of
`Documentation/Architecture/Hosting and deployment.md`, which records what would
be involved and the one limit that cannot be undone.

## Custom domain

A custom domain (e.g. `evesexperiment.com`, ~$10-12/yr) was offered as an
alternative to the free `pages.dev` subdomain and not taken.

*If picked up:* Cloudflare Pages attaches one in a few clicks. Enable WHOIS
privacy at the registrar, or the registration itself publishes the registrant's
name and address — free at most registrars now, but it has to be on.

## Detect an off-pitch final row without being told

Read unaided, a board whose last row sits well off the row pitch comes out one
row short. The "Rows of tubes in your game" stepper corrects it in one tap, and
every generated board with the count supplied reads correctly.

*Why deferred:* the escape hatch works and is one press. Loosening the pitch
tolerance enough to catch it also lets the game's button bar in as a row, which
is a worse failure because it is silent.

*If picked up:* see the grid fit in
`Documentation/Architecture/Screenshot reader.md`. The trailing-row relaxation
already exists for the guided path; the question is what justifies it when no
count has been given.

## Detect white and grey layers

Both fall under the saturation floor and nothing yet separates them from empty
glass. If a level uses either, those layers read as empty.

*Why deferred:* not seen in the game so far. Pale pink was, and is handled.

*If picked up:* glass is dark and these are bright, which is the same distinction
`isColour` already draws for pale liquids — but white against a bright background
is harder, and the glass highlight is white too.

