# Claude Code status line: account · git branch · model · context size · usage limits.
#
# This file has no shebang on purpose: it is wrapped by writeShellApplication in
# modules/ai.nix, which prepends a pinned bash interpreter and puts jq and git on
# PATH. Claude Code runs the status line with whatever environment it inherited,
# which is not guaranteed to have either tool.
#
# Errors are handled per segment instead of with `set -e`: a value that cannot be
# resolved is dropped from the line rather than blanking the whole status line.
#
# The JSON payload arriving on stdin is documented at
# https://code.claude.com/docs/en/statusline

# Slurp the payload with the read builtin (-d '' reads up to EOF) so that jq and
# git, both pinned by the wrapper, stay the script's only external dependencies.
IFS= read -r -d '' input

# Claude Code renders the status line dimmed, so colour is used sparingly — only
# to flag usage limits that are close to running out.
dim=$'\033[2m'
red=$'\033[31m'
yellow=$'\033[33m'
reset=$'\033[0m'

# Read a field from the payload, printing nothing when it is absent or null.
field() {
  jq -r "$1 // empty" <<<"$input" 2>/dev/null
}

segments=()

# The account is not part of the status line payload, so it is read from the
# state file Claude Code writes at login.
account=$(jq -r '.oauthAccount | .emailAddress // .displayName // empty' \
  "$HOME/.claude.json" 2>/dev/null)
[ -n "$account" ] && segments+=("$account")

cwd=$(field '.workspace.current_dir // .cwd')
if [ -n "$cwd" ]; then
  # --no-optional-locks keeps the status line, which re-runs on every update,
  # from competing with foreground git commands for the index lock.
  branch=$(git --no-optional-locks -C "$cwd" branch --show-current 2>/dev/null)
  # A detached HEAD has no branch name; show the commit it points at instead.
  if [ -z "$branch" ]; then
    branch=$(git --no-optional-locks -C "$cwd" rev-parse --short HEAD 2>/dev/null)
  fi
  [ -n "$branch" ] && segments+=("$branch")
fi

model=$(field '.model.display_name')
[ -n "$model" ] && segments+=("$model")

# Tokens currently in the context window, against the window size of the model.
# Absent until the first API response of the session has landed.
context=$(jq -r '
  .context_window
  | select(. != null and .total_input_tokens > 0)
  | "\(.total_input_tokens / 1000 | round)k/\(.context_window_size / 1000 | round)k"
' <<<"$input" 2>/dev/null)
[ -n "$context" ] && segments+=("$context")

# Append a subscription usage limit. These are only reported for Claude.ai
# subscribers, and only after the first API response of the session. Rounding
# happens in jq rather than in printf, which rejects a fractional percentage in
# locales that do not use "." as the decimal separator.
add_limit() {
  local label=$1 window=$2 used colour
  used=$(jq -r "(.rate_limits.${window}.used_percentage // empty) | round" \
    <<<"$input" 2>/dev/null)
  [ -n "$used" ] || return 0
  if [ "$used" -ge 90 ]; then
    colour=$red
  elif [ "$used" -ge 75 ]; then
    colour=$yellow
  else
    colour=""
  fi
  segments+=("${colour}${label} ${used}%${colour:+$reset}")
}

add_limit 5h five_hour
add_limit 7d seven_day

printf '%s' "${segments[0]-}"
for segment in "${segments[@]:1}"; do
  printf '%s' "${dim} · ${reset}${segment}"
done
