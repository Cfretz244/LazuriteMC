# Discord Collaboration Channel — Operator Notes

How the project's Discord bug-reporting / collaboration channel is wired up, so it can be
rebuilt or maintained without rediscovering everything.

**What it is:** a shared Discord channel (`#bugs`) connected to Claude Code via the official
**Channels** plugin. Testers paste errors and chat with Claude in plain language; the
maintainer sees every message and can jump in. Claude runs with this repo as its working
directory, so it has full code context. (Bug reports can also be filed as GitHub issues via
`REPORTING-BUGS.md` / the issue form — that's the structured-tracking backend.)

---

## ⚠️ The non-obvious prerequisite: install `bun`

The Channels plugin runs its Discord gateway server with **bun** (`bun run … start` in the
plugin's `.mcp.json`). If `bun` isn't installed, the MCP server never starts, the bot stays
**grey/offline**, and nothing comes through. The tell-tale error is:

```
Failed to reconnect to plugin:discord:discord: ENOENT
```

Fix:
```sh
brew install bun
```
Then **restart** the `claude --channels` session (it can't pick up a newly-installed binary
mid-run). Node is not a substitute — the launch command hardcodes `bun`.

---

## One-time setup

### 1. Create the bot (Discord Developer Portal)
1. <https://discord.com/developers/applications> → **New Application**.
2. **Bot** (sidebar) → **Reset Token** → copy the token (shown once).
3. **Bot → Privileged Gateway Intents** → enable **Message Content Intent** (enabling all
   three — Presence, Server Members, Message Content — is the safe move; a disallowed intent
   the server requests causes the gateway to reject the whole connection → grey bot).

### 2. Invite the bot to the server
1. **OAuth2 → URL Generator**.
2. Scopes: **`bot`**. Permissions: **View Channels**, **Send Messages**, **Read Message
   History** (+ Embed Links / Attach Files / Add Reactions recommended).
3. Open the generated URL, pick the server, **Authorize**.
   (Saving the token does NOT add the bot to a server — this step does. If `@` doesn't
   autocomplete the bot in a channel, it was never invited.)

### 3. Install + configure the plugin (in a Claude Code session)
```
/plugin install discord@claude-plugins-official
/reload-plugins
/discord:configure <bot-token>
```
This writes the token to `~/.claude/channels/discord/.env` (chmod 600).

### 4. Set access (in a Claude Code session)
Access state lives in `~/.claude/channels/discord/access.json` (re-read on every message —
changes take effect immediately, no restart):
```
/discord:access allow <maintainer-user-id>
/discord:access allow <tester-user-id>
/discord:access group add <channel-id>                 # opt the channel in (requires an @mention to trigger)
/discord:access policy allowlist                       # lock down DMs to allowlisted users only
```
Get user/channel IDs: Discord → **Settings → Advanced → Developer Mode**, then right-click a
user or channel → **Copy ID**.

---

## Going live
Run from the repo directory (so Claude has code context):
```sh
cd ~/git/LazuriteMC
claude --channels plugin:discord@claude-plugins-official
```
The bot is only reachable while this session runs. The Claude window looks normal aside from
a "Channels (experimental)" banner; Discord messages inject into that session.

**Always-on** (so testers can reach it anytime):
- **Local Mac:** run inside `tmux`, and prevent sleep with `caffeinate -dimsu` in another
  pane. Mac must stay powered on.
- **VPS:** clone the repo, install JDK 25 + bun, run the same command under `tmux`.

---

## Day-to-day

- **Add someone:** `/discord:access allow <user-id>` (Copy ID first).
- **Remove someone:** `/discord:access remove <user-id>`.
- **Mention vs. no-mention:** the channel is configured to require an **@mention** (so the
  bot ignores ordinary chatter). To make it reply to every message instead, re-add the group
  with `--no-mention`: `/discord:access group add <channel-id> --no-mention`.
- **Check status:** `/discord:access` (no args) shows policy, allowlist, and groups.

## Security boundary
Messages arriving *through Discord* are treated as untrusted (prompt-injection risk). Claude
will not perform access changes or destructive/outward actions based on chat messages — those
only happen from commands typed directly in the terminal session. This holds regardless of
how trusted the participants are.

## Troubleshooting: bot is grey / not replying
1. **`bun` not installed** → `brew install bun`, restart session. (Most common; ENOENT.)
2. **Disallowed intent** → enable the privileged intents in the portal, restart session.
3. **Session started before a fix** → the session can't pick up changes to binaries/intents
   mid-run; Ctrl-C and relaunch.
4. **`@` doesn't autocomplete the bot** → bot was never invited (do the OAuth2 step).
5. **Sanity-check from the API** (valid token, server membership, channel access):
   ```sh
   source ~/.claude/channels/discord/.env
   curl -s -H "Authorization: Bot $DISCORD_BOT_TOKEN" https://discord.com/api/v10/users/@me/guilds
   ```

## Credential note
The bot token is a secret, stored only in `~/.claude/channels/discord/.env` (not in this
repo). If it's ever exposed, reset it in Developer Portal → Bot → Reset Token and re-run
`/discord:configure`.
