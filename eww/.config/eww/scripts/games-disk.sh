#!/usr/bin/env bash
# ~/Games usage → JSON for eww. du is expensive → cached 1h in /tmp.
G="$HOME/Games"
CACHE=/tmp/oni-games-du
read -r TOTAL USED FREE PCT < <(df -B1G --output=size,used,avail,pcent "$G" | tail -1 | tr -d '%')

if [ ! -f "$CACHE" ] || [ $(( $(date +%s) - $(stat -c %Y "$CACHE") )) -gt 3600 ]; then
  { for d in SteamLibrary Battlenet Minecraft Heroic; do
      [ -d "$G/$d" ] && printf '%s %s\n' "$d" "$(du -sBG "$G/$d" 2>/dev/null | cut -f1)"
    done > "$CACHE"; } &
fi
LEGEND=$(awk '{printf "%s %s · ", tolower(substr($1,1,5)), $2}' "$CACHE" 2>/dev/null | sed 's/ · $//')

jq -nc --arg f "${FREE}G" --arg t "${TOTAL}G" --argjson p "${PCT:-0}" --arg l "${LEGEND:-scanning…}" \
  '{free:$f, total:$t, pct:$p, legend:$l}'
