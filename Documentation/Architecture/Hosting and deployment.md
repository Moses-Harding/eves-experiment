# Hosting and deployment

Set up 2026-09-29.

## Where it lives

| | |
|---|---|
| Live site | https://eves-experiment.pages.dev |
| Host | Cloudflare Pages, project `eves-experiment`, production branch `main` |
| Upload method | Direct upload (**not** git-connected) |
| Source | https://github.com/Moses-Harding/eves-experiment (public, MIT) |
| GitHub Pages | **Deliberately disabled.** See "One URL on purpose". |

The Cloudflare account is whichever one `npx wrangler login` authorized on this
machine; run `npx wrangler whoami` to confirm which. Credentials persist in
`~/Library/Preferences/.wrangler`, so the login is a one-time step per machine.

## Redeploying

```
./deploy.sh
```

That is the whole process. **Pushing to GitHub publishes nothing** — the Pages
project is a direct upload with no repository connection, so the site only
changes when `deploy.sh` runs. This is easy to forget: a push that looks like a
release does not touch the live site.

If `deploy.sh` is ever lost, the equivalent is:

```
stage=$(mktemp -d) && cp index.html "$stage/" \
  && npx wrangler pages deploy "$stage" --project-name eves-experiment \
       --branch main --commit-dirty=true
```

## Why the deploy stages a temp directory

A Cloudflare Pages direct upload publishes an **entire directory**. Deploying
the repository root would therefore serve `README.md`, `LICENSE` and now
`Documentation/` from the live domain. `LICENSE` carries a copyright line with
the author's legal name, which defeats the point of the neutral URL.

`deploy.sh` copies only `index.html` into a fresh temp directory and uploads
that. The deployed surface is exactly one file.

**If you add a real asset** (an image, a separate stylesheet, a `solver.js`),
it must be added to the `cp` line in `deploy.sh` or it will 404 in production
while working perfectly in local testing. Consider moving to a tracked
`public/` directory at that point instead of maintaining a copy list.

## Why Cloudflare Pages and not Workers

Cloudflare is folding Pages into Workers, and `wrangler pages` commands now try
to delegate to Workers. This project resists that on purpose:

- A Worker is served from `<name>.<account-subdomain>.workers.dev`. The account
  subdomain is derived from the account and is exactly the kind of hostname
  segment that can carry a personal name.
- A Pages project is served from `<name>.pages.dev`, with no account component.

Since a name-free hostname was the whole requirement, Pages is the right
backend. Creating the project therefore needed `--force` to bypass delegation:

```
npx wrangler pages project create eves-experiment --production-branch main --force
```

`--force` was needed **once, at creation only**. The project now exists as a
Pages project, so ordinary `wrangler pages deploy` runs against Pages directly.
Do not add `--force` to `deploy.sh`.

Note that `wrangler pages project create` run from a directory with no static
files fails with "Could not detect a directory containing static files" — run it
from somewhere containing an `index.html`, or just create it via `--force` as
above.

## One URL on purpose

GitHub Pages was enabled first, at `moses-harding.github.io/eves-experiment`,
then switched off once Cloudflare was verified working, so that the app is
reachable at a single name-free address rather than two addresses one of which
carries a name.

Re-enable it if ever wanted:

```
gh api -X POST repos/Moses-Harding/eves-experiment/pages \
  -f "source[branch]=main" -f "source[path]=/"
```

Turn it back off:

```
gh api -X DELETE repos/Moses-Harding/eves-experiment/pages
```

The repository stays public either way, so the source is always browsable at
`raw.githubusercontent.com` regardless of whether Pages is serving.

## Identity surface

The decision taken was "a neutral URL is enough" — not full pseudonymity. The
live domain is clean; the source repository is openly the author's. Concretely:

- `index.html`, the only deployed file, contains no name, email or local path.
  Verified by grep, and by confirming zero name matches on every probed path of
  the live domain.
- The author's name remains in `LICENSE`, in the commit author and committer
  fields throughout history, and in the repository path itself.

Going further would mean rewriting history to scrub the author fields, changing
the `LICENSE` holder, deleting rather than transferring the existing repository
(GitHub leaves a redirect behind on transfer, which would defeat it), and
republishing from a neutral identity. One limit to know: the repository was
public from creation, and GitHub publishes public repository events to a
firehose that third parties archive permanently, so the association may already
be recorded somewhere beyond reach.

## Testing locally

```
python3 -m http.server 8931
```

**Hard-reload when testing** (Cmd+Shift+R), or append `?v=2` to the URL. This
server allows browser caching of `index.html`, and a plain reload will quietly
serve an older copy — a test has already failed here against code that was
definitely on disk.

Real game screenshots can be dropped in the project root for debugging the
reader; `*.png` is git-ignored because this repository is public, and
`deploy.sh` stages only `index.html`, so they cannot reach the live site either.

## Verifying a deploy

What was checked after the first deploy, worth repeating after any significant
change:

```
# serving, and content-type is html rather than plain text
curl -sI https://eves-experiment.pages.dev/ | grep -iE '^(HTTP|content-type)'

# what is served matches what is local, byte for byte
curl -s https://eves-experiment.pages.dev/ -o /tmp/dl.html
shasum -a256 /tmp/dl.html index.html | awk '{print $1}' | uniq -c   # expect "2 <hash>"

# nothing personal reachable on the neutral domain
for p in "" LICENSE README.md .gitignore; do
  curl -s "https://eves-experiment.pages.dev/$p" | grep -ciE 'moses|harding|moseshh'
done                                                                # expect all 0
```

Unknown paths return **200 with `index.html`**, not 404 — Cloudflare Pages
falls back to the index. So a 200 on `/LICENSE` does not mean `LICENSE` was
uploaded; check the body or the size, not the status code. A screenshot left in
the project root returns 200 at its path, with the page's bytes rather than the
image's — which is how you tell it was not published.

## Properties of the app that affect hosting

- **Self-contained.** One static HTML file. No build step, no dependencies, no
  server, no runtime configuration.
- **Makes no network requests of its own.** No `fetch`, XHR, WebSocket or
  beacon anywhere. Screenshot parsing is entirely client-side; nothing is
  uploaded. The only external request is the Google Fonts stylesheet.
- **Needs a secure context.** The copy-link button uses
  `navigator.clipboard.writeText`, which requires HTTPS or localhost. Opening
  `index.html` from disk falls back to the deprecated `execCommand` path. Serve
  it (`python3 -m http.server 8000`) when testing locally.
- **Share links are hash-based** (`history.replaceState` in `index.html`), so
  they survive being hosted under a subpath and need no per-host configuration.
- **Board state persists in `localStorage`** under `eves-experiment:*` keys.
