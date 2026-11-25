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

asumi_progress="${ASUMI_PROGRESS_FILE:-$HOME/.local/state/asumi/progress.json}"
asumi_attention=0
asumi_tooltip=""
if [[ -r "$asumi_progress" ]] && jq -e '.headline | type == "string" and length > 0' "$asumi_progress" >/dev/null 2>&1; then
  headline=$(jq -r '.headline' "$asumi_progress" | tr '\n\t' '  ' | cut -c1-60 | sed 's/[[:space:]]*$//')
  attention=$(jq -r '.attention // false' "$asumi_progress")
  updated=$(jq -r '.updated // ""' "$asumi_progress")
  asumi_lines=()
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    asumi_lines+=("・$(printf '%s' "$line" | tr '\n\t' '  ' | cut -c1-60)")
  done < <(jq -r '(.lines // [])[]' "$asumi_progress" 2>/dev/null)
  asumi_tooltip="asumi: ${headline}"
  if (( ${#asumi_lines[@]} > 0 )); then
    asumi_tooltip+=$'\n'
    asumi_tooltip+=$(printf '%s\n' "${asumi_lines[@]:0:6}")
    if (( ${#asumi_lines[@]} > 6 )); then
      asumi_tooltip+=$'\n'"… ほか $(( ${#asumi_lines[@]} - 6 )) 件"
    fi
  fi
  [[ -n "$updated" ]] && asumi_tooltip+=$'\n'"updated ${updated}"
  [[ "$attention" == "true" ]] && asumi_attention=1
fi

tooltip=""
if [[ -n "$asumi_tooltip" ]]; then
  tooltip="${asumi_tooltip}"$'\n'
fi
tooltip+="Needs you ${needs} / In progress ${progress}"
if (( ${#items[@]} > 0 )); then
  tooltip+=$'\n'
  tooltip+=$(printf '%s\n' "${items[@]:0:6}")
  if (( ${#items[@]} > 6 )); then
    tooltip+=$'\n'"… ほか $(( ${#items[@]} - 6 )) 件"
  fi
else
  tooltip+=$'\nNeeds you はありません'
fi

text="󰚩 ${needs}"
(( asumi_attention )) && text+=" ◆"

class=""
if (( needs > 0 )) || (( asumi_attention )); then
  class="active"
fi

output=$(jq -cn --arg text "$text" --arg tooltip "$tooltip" --arg class "$class" '{text:$text, tooltip:$tooltip, class:$class}')
printf '%s\n' "$output" | tee "$cache_file"
