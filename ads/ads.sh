#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_DIR="${ADS_TEMPLATES_DIR:-$SCRIPT_DIR/templates}"
FORCE=false

# Tool configs: each entry is "tool|description|source_template|target_path"
CONFIGS=(
  "claude|Claude Code|claude/settings.json|$HOME/.claude/settings.json"
)

usage() {
  echo "Usage: ads <command> [args]"
  echo ""
  echo "Commands:"
  echo "  config list               List available tools and their managed files"
  echo "  config init <tool>        Seed configuration files for a tool"
  echo "  config init --all         Seed configuration files for all tools"
  echo ""
  echo "Options:"
  echo "  --force                 Overwrite existing config files (use with config init)"
}

config_list() {
  echo "Available tools:"
  local current_tool=""
  for entry in "${CONFIGS[@]}"; do
    IFS='|' read -r tool description template target <<< "$entry"
    if [[ "$tool" != "$current_tool" ]]; then
      echo -e "  \033[1m${tool}\033[0m (${description})"
      current_tool="$tool"
    fi
    echo "    - $target"
  done
}

config_init() {
  local tool="$1"
  local found=false

  for entry in "${CONFIGS[@]}"; do
    IFS='|' read -r entry_tool description template target <<< "$entry"
    if [[ "$entry_tool" != "$tool" ]]; then
      continue
    fi
    found=true

    local src="$TEMPLATES_DIR/$template"

    if [[ ! -f "$src" ]]; then
      echo "Error: Template not found: $src" >&2
      exit 1
    fi

    if [[ -e "$target" ]] && [[ "$FORCE" == false ]]; then
      echo "Skipped: $target already exists (use --force to overwrite)"
    else
      local verb="Created"
      [[ -e "$target" ]] && verb="Overwritten"
      mkdir -p "$(dirname "$target")"
      cp "$src" "$target"
      chmod 644 "$target"
      echo "$verb: $target"
    fi
  done

  if [[ "$found" == false ]]; then
    echo "Error: Unknown tool '$tool'. Run 'ads config list' to see available tools." >&2
    exit 1
  fi
}

config_init_all() {
  echo "This will initialize configuration files for all available tools:"
  config_list
  echo ""
  read -rp "Proceed? [y/N] " answer
  if [[ "$answer" != [yY] ]]; then
    echo "Aborted."
    exit 0
  fi
  echo ""

  local tools=()
  for entry in "${CONFIGS[@]}"; do
    IFS='|' read -r tool _ _ _ <<< "$entry"
    if [[ ! " ${tools[*]:-} " =~ " $tool " ]]; then
      tools+=("$tool")
    fi
  done

  for tool in "${tools[@]}"; do
    config_init "$tool"
  done
}

config_init_cmd() {
  local target_tool=""
  local all=false
  for arg in "$@"; do
    case "$arg" in
      --force) FORCE=true ;;
      --all) all=true ;;
      -*) echo "Error: Unknown option '$arg'" >&2; usage; exit 1 ;;
      *) target_tool="$arg" ;;
    esac
  done
  if [[ "$all" == true ]]; then
    config_init_all
  elif [[ -n "$target_tool" ]]; then
    config_init "$target_tool"
  else
    echo "Error: Missing tool name. Usage: ads config init <tool> [--force]" >&2
    exit 1
  fi
}

if [[ $# -lt 1 ]]; then
  usage
  exit 1
fi

case "$1" in
  config)
    if [[ $# -lt 2 ]]; then
      usage
      exit 1
    fi
    case "$2" in
      list)
        config_list
        ;;
      init)
        shift 2
        config_init_cmd "$@"
        ;;
      *)
        echo "Error: Unknown config command '$2'" >&2
        usage
        exit 1
        ;;
    esac
    ;;
  *)
    echo "Error: Unknown command '$1'" >&2
    usage
    exit 1
    ;;
esac
