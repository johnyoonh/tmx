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
| `git log` | `tmx log` | List saved snapshots |
| `git clean -n/-fd` | `tmx clean -n`, `tmx clean` | Preview or kill detached sessions |

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

## Metadata

`tmx` stores session metadata in tmux user options:

- `@tmx.dir`: directory associated with the session
- `@tmx.tags`: comma-separated session tags

For compatibility while migrating from local scripts, `tmx list` also reads
legacy `@dir_path` values.

## Alternate tmux sockets

Use `TMX_TMUX_ARGS` for isolated sockets or custom tmux configs:

```sh
TMX_TMUX_ARGS='-L work' tmx list
```

Remote profiles are intentionally not part of v1. They are planned as a future
layer over alternate sockets, configs, and SSH commands.

