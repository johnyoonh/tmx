# tmx

`tmx` is pronounced **T-max**.

`tmx` is a Git-inspired workflow layer for tmux. It gives tmux sessions the
kind of short, memorable commands many people already use for Git: `status`,
`list`, `switch`, `tag`, `snapshot`, `log`, and `clean`.

It is intentionally thin. `tmx` does not replace tmux, and it does not wrap the
`tmux` binary. It calls tmux underneath and stores small bits of metadata in
tmux user options.

## Install

Clone the repo and put `bin` on your `PATH`, or symlink the executable:

```sh
ln -s "$HOME/github/tmx/bin/tmx" "$HOME/.local/bin/tmx"
```

For a short personal command:

```sh
alias t=tmx
```

Requirements:

- `tmux`
- `fzf` for the interactive chooser
- `tmux-resurrect` for `tmx snapshot` / `tmx commit`

`tmux-continuum` is not required. It can autosave tmux-resurrect snapshots if
you already use it, but `tmx` only calls tmux-resurrect directly.

## Commands

| Git habit | tmx command | Tmux behavior |
| --- | --- | --- |
| `git status` | `tmx status`, `tmx s` | Show current session, sessions, tags, latest snapshot |
| `git branch` | `tmx list`, `tmx ls`, `tmx l` | List tmux sessions sorted by recent activity |
| `git checkout foo` | `tmx switch foo`, `tmx co foo` | Switch or attach to a session |
| `git checkout -b foo` | `tmx new foo`, `tmx n foo` | Create a new session |
| project worktree | `tmx here`, `tmx h` | Create or attach a session for the current directory |
| picker workflow | `tmx`, `tmx choose`, `tmx c` | Open a fuzzy session chooser |
| `git tag` | `tmx tag add/remove/list` | Store labels on tmux sessions |
| `git commit` | `tmx snapshot`, `tmx commit` | Save tmux state with tmux-resurrect |
| `git diff` | `tmx diff [snapshot]` | Compare a saved snapshot with live tmux state |
| `git log` | `tmx log` | List saved snapshots |
| `git clean -n/-fd` | `tmx clean -n`, `tmx clean` | Preview or kill detached sessions |
| `git remote` | `tmx remote` | Manage named tmux server profiles |

## Examples

Create or switch to a session for the current directory:

```sh
tmx here
```

Switch to an existing session:

```sh
tmx co codex
```

Tag the current session:

```sh
tmx tag add ai
tmx list --tag ai
```

Save a tmux snapshot:

```sh
tmx snapshot -m "working agent layout"
tmx log
```

`tmx commit` is an alias for `tmx snapshot`.

Important: snapshots are tmux snapshots, not Git commits. They capture tmux
layout, windows, panes, commands, and plugin-supported editor session state.
They do not capture filesystem state.

Clean detached sessions:

```sh
tmx clean --dry-run
tmx clean
```

Compare live tmux state with a saved snapshot:

```sh
tmx diff
tmx diff tmux_resurrect_2026-05-29T190000.txt
```

## Remotes and sockets

In `tmx`, a remote is a named tmux connection profile. It is closer to "which
tmux server/socket should I operate on?" than Git's distributed repository
sync model.

Add and use a profile:

```sh
tmx remote add work --tmux-args '-L work'
tmx --remote work list
tmx -r work status
```

Use one-off socket selectors:

```sh
tmx --tmux-args '-L codex' ls
tmx --socket-name codex status
tmx --socket-path /tmp/tmux-custom list
```

Remote profiles are stored in:

```text
~/.config/tmx/config
```

## Metadata

`tmx` stores session metadata in tmux user options:

- `@tmx.dir`: directory associated with the session
- `@tmx.tags`: comma-separated session tags
- `@tmx.remote`: remote/profile that created the session, when applicable

For compatibility while migrating from local scripts, `tmx list` also reads
legacy `@dir_path` values.
