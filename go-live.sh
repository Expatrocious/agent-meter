#!/bin/bash
# Puts the agent meter r1 creation on GitHub and starts the PC publisher.
# Safe to run again: each step skips what is already done.
#   1. public repo Expatrocious/agent-meter with this folder (code + tiger icon, no secrets)
#   2. GitHub Pages from docs/  ->  https://expatrocious.github.io/agent-meter/
#   3. agent-meter setup: a secret gist for the usage numbers, agent-meter.service,
#      and the install QR in ~/Pictures/agent-meter-qr.png
set -euo pipefail
cd "$(dirname "$0")"
REPO=Expatrocious/agent-meter
SITE=https://expatrocious.github.io/agent-meter/

echo "1/3 repo"
if gh repo view "$REPO" >/dev/null 2>&1; then
  git remote get-url origin >/dev/null 2>&1 || git remote add origin "https://github.com/$REPO.git"
  git push -u origin main
else
  gh repo create "$REPO" --public --source . --remote origin --push \
    --description "rabbit r1 creation: Claude usage at a glance (rings, reset countdowns)"
fi

echo "2/3 GitHub Pages"
if ! gh api "repos/$REPO/pages" >/dev/null 2>&1; then
  gh api --method POST "repos/$REPO/pages" -f 'source[branch]=main' -f 'source[path]=/docs' >/dev/null
fi
for i in $(seq 1 60); do
  code=$(curl -s -o /dev/null -w '%{http_code}' "${SITE}app.js" || true)
  [[ $code == 200 ]] && break
  sleep 5
done
[[ ${code:-} == 200 ]] && echo "   live: $SITE" || echo "   not live yet (GitHub can take a few minutes); carrying on"

echo "3/3 gist, service, QR"
"$HOME/.local/bin/agent-meter" setup
echo
echo "Scan this on the r1 (creations > create > add via QR code), or open ~/Pictures/agent-meter-qr.png:"
qrencode -t ANSIUTF8 -m 2 -l M "$("$HOME/.local/bin/agent-meter" qr-text)"
