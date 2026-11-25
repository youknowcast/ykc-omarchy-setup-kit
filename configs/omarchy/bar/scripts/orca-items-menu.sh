#!/usr/bin/env bash
set -uo pipefail

export PATH="$HOME/.config/orca/linux-orca-cli-shim:$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin:${PATH:-}"

mode="needs"
dry=0
for arg in "$@"; do
  case "$arg" in
    --all) mode="all" ;;
    --dry-run) dry=1 ;;
  esac
done

status=$(orca status --json 2>/dev/null) || {
  omarchy menu select "Orca items" "Orca CLI に接続できません"
  exit 0
}
if [[ "$(jq -r '.result.app.running // false' <<<"$status" 2>/dev/null)" != "true" ]]; then
  selected=$(omarchy menu select "Orca items" "Orca は起動していません" "Orca を起動する") || exit 0
  if [[ "$selected" == "Orca を起動する" ]]; then
    nohup orca open >/dev/null 2>&1 &
  fi
  exit 0
fi

bots_json=$(orca bot list --json 2>/dev/null) || {
  omarchy menu select "Orca items" "orca bot list に失敗（サインイン？）"
  exit 0
}
mapfile -t bots < <(jq -r '.result.bots[]? | [.name, .id] | @tsv' <<<"$bots_json" 2>/dev/null)

labels=()
ids=()

for row in "${bots[@]}"; do
  [[ -z "$row" ]] && continue
  name=${row%%$'\t'*}
  id=${row#*$'\t'}
  json=$(timeout 8 orca bot item list --bot "$name" --json 2>/dev/null) || continue
  if [[ "$mode" == "all" ]]; then
    while IFS=$'\t' read -r number title st; do
      [[ -z "$number" ]] && continue
      title=$(printf '%s' "$title" | tr '\n\t' '  ' | cut -c1-56)
      labels+=("${name} · #${number} ${title} · ${st}")
      ids+=("$id")
    done < <(jq -r '.result.items[]? | [.number, .title, .status] | @tsv' <<<"$json" 2>/dev/null)
  else
    while IFS=$'\t' read -r number title; do
      [[ -z "$number" ]] && continue
      title=$(printf '%s' "$title" | tr '\n\t' '  ' | cut -c1-56)
      labels+=("${name} · #${number} ${title}")
      ids+=("$id")
    done < <(jq -r '.result.items[]? | select(.status == "needs_you") | [.number, .title] | @tsv' <<<"$json" 2>/dev/null)
  fi
done

if (( ${#labels[@]} == 0 )); then
  if (( dry )); then
    echo "item はありません"
    exit 0
  fi
  if [[ "$mode" == "all" ]]; then
    omarchy menu select "Orca items" "開いている item はありません" >/dev/null
  else
    omarchy menu select "Orca items" "Needs you はありません" >/dev/null
  fi
  exit 0
fi

declare -A label_to_id=()
options=()
for i in "${!labels[@]}"; do
  label="${labels[$i]}"
  if [[ -n "${label_to_id[$label]:-}" ]]; then
    label+=" (#$((i + 1)))"
  fi
  label_to_id["$label"]="${ids[$i]}"
  options+=("$label")
done

if (( dry )); then
  printf '%s\n' "${options[@]}"
  exit 0
fi

selected=$(omarchy menu select "Orca items" "${options[@]:0:40}") || exit 0
[[ -z "$selected" ]] && exit 0
bot_id="${label_to_id[$selected]:-}"
[[ -z "$bot_id" ]] && exit 0

nohup stably-orca "orca://bot/${bot_id}" >/dev/null 2>&1 &
