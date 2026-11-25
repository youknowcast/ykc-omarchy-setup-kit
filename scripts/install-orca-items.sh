#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
prefix=${HOME:?HOME is not set}
dry_run=0

usage() {
  cat <<'USAGE'
Usage: scripts/install-orca-items.sh [--dry-run] [--prefix DIR]

Copies the Orca items bar scripts into DIR/.config/omarchy/bar/scripts/ and
merges the orca.items entry into DIR/.config/omarchy/shell.json. DIR defaults
to $HOME. Other bar settings and other widget entries are left untouched.
USAGE
}

while (( $# > 0 )); do
  case "$1" in
    --dry-run)
      dry_run=1
      shift
      ;;
    --prefix)
      if (( $# < 2 )); then
        echo "error: --prefix requires a directory" >&2
        exit 2
      fi
      prefix=$2
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "error: unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

src_dir="$repo_root/configs/omarchy/bar/scripts"
dest_dir="$prefix/.config/omarchy/bar/scripts"
shell_json="$prefix/.config/omarchy/shell.json"
scripts=(orca-items.sh orca-items-menu.sh orca-items-copy.sh)

for cmd in jq bash; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "error: $cmd is required" >&2
    exit 1
  fi
done

for cmd in orca stably-orca omarchy omarchy-menu-select wl-copy notify-send; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "warning: $cmd not found; the corresponding bar action will not work" >&2
  fi
done

if [[ ! -f "$shell_json" ]]; then
  echo "error: $shell_json not found; start Omarchy once so the shell config exists" >&2
  exit 1
fi

for name in "${scripts[@]}"; do
  if [[ ! -f "$src_dir/$name" ]]; then
    echo "error: $src_dir/$name is missing" >&2
    exit 1
  fi
  if (( dry_run )); then
    echo "would install $dest_dir/$name (mode 755)"
  else
    install -Dm755 "$src_dir/$name" "$dest_dir/$name"
    echo "installed $dest_dir/$name"
  fi
done

entry='{"id":"orca.items","type":"command","exec":"~/.config/omarchy/bar/scripts/orca-items.sh","interval":30,"tooltip":"Orca items","onClick":"~/.config/omarchy/bar/scripts/orca-items-menu.sh","onRightClick":"~/.config/omarchy/bar/scripts/orca-items-menu.sh --all","onMiddleClick":"~/.config/omarchy/bar/scripts/orca-items-copy.sh"}'

merged=$(jq --argjson entry "$entry" '
  (.bar.layout.right // []) as $right
  | ([$right | to_entries[] | select(.value.id == "orca.items") | .key][0]) as $at
  | if $at != null then
      .bar.layout.right =
        ($right
         | to_entries
         | map(if .key == $at then $entry
               elif .value.id == "orca.items" then empty
               else .value
               end))
    else
      ([$right | to_entries[] | select(.value.id == "omarchy.agents") | .key][0]) as $index
      | .bar.layout.right =
          (if $index == null then
             $right + [$entry]
           else
             $right[0:$index] + [$entry] + $right[$index:]
           end)
    end
' "$shell_json")

if ! jq -e '.bar.layout.right | any(.id == "orca.items")' >/dev/null <<<"$merged"; then
  echo "error: failed to build a shell.json containing orca.items" >&2
  exit 1
fi

current=$(cat "$shell_json")
if [[ "$merged" == "$current" ]]; then
  echo "shell.json already contains orca.items; unchanged"
elif (( dry_run )); then
  echo "would update $shell_json:"
  printf '%s\n' "$merged"
else
  backup="$shell_json.bak.$(date +%Y%m%d-%H%M%S)"
  cp -p "$shell_json" "$backup"
  tmp=$(mktemp "$(dirname "$shell_json")/.shell.json.XXXXXX")
  printf '%s\n' "$merged" >"$tmp"
  chmod --reference="$shell_json" "$tmp"
  mv "$tmp" "$shell_json"
  echo "updated $shell_json (backup: $backup)"
fi

if (( dry_run )); then
  echo "dry run complete; nothing was written"
else
  echo "Orca items widget installed; Omarchy reloads shell.json on save"
fi
