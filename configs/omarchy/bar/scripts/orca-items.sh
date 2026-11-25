#!/usr/bin/env bash
set -uo pipefail

export PATH="$HOME/.config/orca/linux-orca-cli-shim:$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin:${PATH:-}"

cache_dir="${XDG_RUNTIME_DIR:-/tmp}/orca-items"
cache_file="$cache_dir/state.json"
mkdir -p "$cache_dir" 2>/dev/null || true

fail() {
  local msg="$1"
  if [[ -s "$cache_file" ]] && jq -e . "$cache_file" >/dev/null 2>&1; then
    local text tooltip
    text=$(jq -r '.text // "󰚩 ?"' "$cache_file" 2>/dev/null)
    tooltip=$(jq -r '.tooltip // ""' "$cache_file" 2>/dev/null)
    jq -cn --arg text "${text} !" --arg tooltip "${tooltip}"$'\n'"⚠ ${msg}" '{text:$text, tooltip:$tooltip, class:""}'
  else
    jq -cn --arg msg "$msg" '{text:"󰚩 ?", tooltip:("Orca items\n⚠ " + $msg), class:""}'
  fi
  exit 0
}

command -v orca >/dev/null 2>&1 || fail "orca CLI が見つかりません"

status=$(orca status --json 2>/dev/null) || fail "orca status に失敗"
if [[ "$(jq -r '.result.app.running // false' <<<"$status" 2>/dev/null)" != "true" ]]; then
  fail "Orca は起動していません"
fi

bots_json=$(orca bot list --json 2>/dev/null) || fail "orca bot list に失敗（サインインが必要かもしれません）"
mapfile -t bots < <(jq -r '.result.bots[]? | [.name, .id] | @tsv' <<<"$bots_json" 2>/dev/null)

needs=0
progress=0
items=()

for row in "${bots[@]}"; do
  [[ -z "$row" ]] && continue
  name=${row%%$'\t'*}
  json=$(timeout 8 orca bot item list --bot "$name" --json 2>/dev/null) || continue
  n=$(jq -r '[.result.items[]? | select(.status == "needs_you")] | length' <<<"$json" 2>/dev/null) || n=0
  p=$(jq -r '.result.counts.in_progress // 0' <<<"$json" 2>/dev/null) || p=0
  needs=$((needs + n))
  progress=$((progress + p))
  if (( n > 0 )); then
    while IFS= read -r title; do
      [[ -z "$title" ]] && continue
      title=$(printf '%s' "$title" | tr '\n\t' '  ' | cut -c1-48)
      items+=("・${name}: ${title}")
    done < <(jq -r '[.result.items[]? | select(.status == "needs_you") | .title] | .[]' <<<"$json" 2>/dev/null)
  fi
done

tooltip="Needs you ${needs} / In progress ${progress}"
if (( ${#items[@]} > 0 )); then
  tooltip+=$'\n'
  tooltip+=$(printf '%s\n' "${items[@]:0:6}")
  if (( ${#items[@]} > 6 )); then
    tooltip+=$'\n'"… ほか $(( ${#items[@]} - 6 )) 件"
  fi
else
  tooltip+=$'\nNeeds you はありません'
fi

class=""
(( needs > 0 )) && class="active"

output=$(jq -cn --arg text "󰚩 ${needs}" --arg tooltip "$tooltip" --arg class "$class" '{text:$text, tooltip:$tooltip, class:$class}')
printf '%s\n' "$output" | tee "$cache_file"
