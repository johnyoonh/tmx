#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
TMX="$ROOT/bin/tmx"
SOCKET="tmx-test-$$"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/tmx-test.XXXXXX")"
TMP_DIR="$(cd "$TMP_DIR" && pwd -P)"

cleanup() {
  tmux -L "$SOCKET" kill-server >/dev/null 2>&1 || true
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

export TMX_TMUX_ARGS="-L $SOCKET"
export TMX_NO_ATTACH=1
export TMX_CONFIG_HOME="$TMP_DIR/config"

assert_contains() {
  local haystack="$1" needle="$2"
  if [[ "$haystack" != *"$needle"* ]]; then
    printf 'expected output to contain %q\noutput:\n%s\n' "$needle" "$haystack" >&2
    exit 1
  fi
}

assert_not_contains() {
  local haystack="$1" needle="$2"
  if [[ "$haystack" == *"$needle"* ]]; then
    printf 'expected output not to contain %q\noutput:\n%s\n' "$needle" "$haystack" >&2
    exit 1
  fi
}

bash -n "$TMX"

mkdir -p "$TMP_DIR/project one" "$TMP_DIR/project_two"

created="$(cd "$TMP_DIR/project one" && "$TMX" here)"
[[ "$created" == "project-one" ]]

list_output="$("$TMX" list)"
assert_contains "$list_output" "project-one"
assert_contains "$list_output" "$TMP_DIR/project one"

"$TMX" new scratch "$TMP_DIR/project_two" >/dev/null
list_output="$("$TMX" ls)"
assert_contains "$list_output" "scratch"

"$TMX" remote add testremote --tmux-args "-L $SOCKET"
remote_output="$("$TMX" remote list)"
assert_contains "$remote_output" "testremote"
remote_here="$(cd "$TMP_DIR/project_two" && "$TMX" --remote testremote here)"
[[ "$remote_here" == "project_two" ]]
remote_list="$("$TMX" -r testremote list)"
assert_contains "$remote_list" "testremote"

socket_output="$(TMX_TMUX_ARGS= "$TMX" --socket-name "$SOCKET" list)"
assert_contains "$socket_output" "project-one"

"$TMX" tag add ai project-one
tags="$("$TMX" tag list project-one)"
assert_contains "$tags" "ai"
tagged="$("$TMX" list --tag ai)"
assert_contains "$tagged" "project-one"
assert_not_contains "$tagged" "scratch"

"$TMX" tag remove ai project-one
tags="$("$TMX" tag list project-one)"
assert_not_contains "$tags" "ai"

tmux -L "$SOCKET" attach-session -d -t project-one >/dev/null 2>&1 || true
dry_run="$("$TMX" clean --dry-run)"
assert_contains "$dry_run" "scratch"
"$TMX" clean >/dev/null
after_clean="$("$TMX" list)"
assert_not_contains "$after_clean" "scratch"

if "$TMX" snapshot -m test >/tmp/tmx-snapshot.out 2>/tmp/tmx-snapshot.err; then
  snapshot="$(cat /tmp/tmx-snapshot.out)"
  [[ -f "$snapshot" ]]
  [[ -f "${snapshot}.tmx-meta" ]]
  "$TMX" diff "$snapshot" >/tmp/tmx-diff.out
else
  snapshot_err="$(cat /tmp/tmx-snapshot.err)"
  if [[ "$snapshot_err" != *"tmux-resurrect save script not found"* &&
        "$snapshot_err" != *"tmux-resurrect did not create a snapshot"* ]]; then
    printf 'unexpected snapshot error:\n%s\n' "$snapshot_err" >&2
    exit 1
  fi
fi

printf 'ok\n'
