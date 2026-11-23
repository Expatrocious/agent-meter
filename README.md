# agent meter

A [rabbit r1](https://www.rabbit.tech/) creation that shows AI agent usage at a
glance. For now that's Claude: the 5-hour session and weekly limits, with
countdowns to when they reset.

![agent meter on the r1](docs/icon.png)

## How it works

```
PC: publisher/agent_meter.py  ──writes──▶  secret gist (usage.json)  ◀──reads──  r1: docs/ on GitHub Pages
```

- **The r1 side** is a static page in `docs/`, served by GitHub Pages at
  <https://expatrocious.github.io/agent-meter/>. The install QR code adds
  `?g=<gist id>&u=<owner>` to that address, so the page knows which gist to read.
- **The PC side** (`publisher/agent_meter.py`, run by `agent-meter.service`)
  reads usage every 2 minutes and writes it to the gist when a number changes,
  or every 10 minutes as a heartbeat. Claude usage comes from Claude Code itself
  (`claude -p` with the `get_usage` control request: no prompt, no model call).
  GitHub access is the `gh` CLI's own login.
- Nothing on the PC is opened to the internet.

What the gist holds: plan name, usage percentages, reset times, and whether the
PC's phone-sessions server is running. No account details or tokens. A secret
gist is unlisted, not private: anyone with the QR code (the gist id) can read it.

## On the r1

- **Rings:** how much of each limit is used. The small dot on a ring is where an
  even pace would be by now; the line below says if you're over or under it.
- **Side button:** check now. **Scroll wheel / tap a ring:** switch reset times
  between a countdown and the clock time. With more agents, the wheel pages
  between them.
- **Footer:** `live` (fresh), `updated …` (older), `PC offline` (nothing new for
  30 minutes), `no connection` (the r1 can't reach GitHub). The last reading
  stays on screen either way.

## On the PC

```
agent-meter setup     create the secret gist (once), start the service, write the QR
agent-meter push      read and publish once, now
agent-meter usage     print the usage JSON (publishes nothing)
agent-meter qr        write the install QR to ~/Pictures/agent-meter-qr.png
agent-meter rotate    new secret gist; old QR codes stop working
```

Settings live in `~/.config/agent-meter/config.json` (gist id; mode 0600).
Logs: `journalctl --user -u agent-meter`.

## Tests

`tests/run.sh` loads the page in headless Chromium at the r1's 240x282 and
answers GitHub's requests itself (35 checks: rings, countdowns, side button,
wheel, rate-limit fallback, offline, stale PC, errors, layout fits).
`python3 -I tests/test_publisher.py` checks the PC side offline (fake gh and
Claude: what gets written, when, and that the gist id never reaches the logs).

To go live (repo, Pages, gist, service, QR) run `./go-live.sh` once.

## Credits

The tiger is the repo owner's own r1-style art.
