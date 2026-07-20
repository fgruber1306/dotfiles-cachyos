#!/usr/bin/env bash
# RetroAchievements → JSON for eww
# Needs ~/.config/oni/ra.env with:  RA_USER=Fabi  RA_KEY=xxxx   (NOT in the repo!)
set -o pipefail
FALLBACK='{"game":"— set up ra.env —","progress":"","pct":0,"last":"","pts":0}'
CFG="$HOME/.config/oni/ra.env"
[ -f "$CFG" ] || { echo "$FALLBACK"; exit 0; }
source "$CFG"

API="https://retroachievements.org/API"
SUM=$(curl -sf --max-time 10 "$API/API_GetUserSummary.php?u=$RA_USER&y=$RA_KEY&g=1&a=1") || { echo "$FALLBACK"; exit 0; }

GID=$(jq -r '.LastGameID // empty' <<<"$SUM")
GAME=$(jq -r '.LastGame.Title // "—"' <<<"$SUM")
LAST=$(jq -r '(.RecentAchievements | to_entries[0].value | to_entries[0].value.Title) // ""' <<<"$SUM" 2>/dev/null)
PTS=$(jq -r '(.RecentAchievements | to_entries[0].value | to_entries[0].value.Points) // 0' <<<"$SUM" 2>/dev/null)

PCT=0; PROG=""
if [ -n "$GID" ]; then
  P=$(curl -sf --max-time 10 "$API/API_GetGameInfoAndUserProgress.php?u=$RA_USER&g=$GID&y=$RA_KEY")
  GOT=$(jq -r '.NumAwardedToUserHardcore // .NumAwardedToUser // 0' <<<"$P")
  ALL=$(jq -r '.NumAchievements // 0' <<<"$P")
  [ "$ALL" -gt 0 ] && PCT=$(( GOT * 100 / ALL )) && PROG="$GOT/$ALL cheevos"
fi

jq -nc --arg g "$GAME" --arg pr "$PROG" --argjson pc "$PCT" --arg l "$LAST" --argjson pt "${PTS:-0}" \
  '{game:$g, progress:$pr, pct:$pc, last:$l, pts:$pt}'
