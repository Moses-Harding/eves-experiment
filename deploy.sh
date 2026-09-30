#!/usr/bin/env bash
# Publish to Cloudflare Pages -> https://eves-experiment.pages.dev
#
# Stages index.html on its own so that README.md, LICENSE and .gitignore are
# never uploaded to the public site. Requires `npx wrangler login` once.
set -euo pipefail
cd "$(dirname "$0")"
stage="$(mktemp -d)"
trap 'rm -rf "$stage"' EXIT
cp index.html "$stage/"
npx --yes wrangler pages deploy "$stage" \
  --project-name eves-experiment \
  --branch main \
  --commit-dirty=true
