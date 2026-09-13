#!/bin/bash

VOL_FILE="$HOME/.config/wayvibes/vol"
PACK_FILE="$HOME/.config/wayvibes/pack"

if pgrep -x "wayvibes" >/dev/null; then
  pkill -x wayvibes
  notify-send -u low -i input-keyboard "打鍵音" "打鍵音をOFFにしました"
else
  CUR_VOL=$(cat "$VOL_FILE" 2>/dev/null || echo "2.5")
  CUR_PACK=$(cat "$PACK_FILE" 2>/dev/null || echo "$HOME/.local/share/soundpacks/nk-cream")
  PIPEWIRE_LATENCY="32/48000" wayvibes "$CUR_PACK" -v "$CUR_VOL" -bg
  PACK_NAME=$(basename "$CUR_PACK")
  notify-send -u low -i input-keyboard "打鍵音" "打鍵音をONにしました ($PACK_NAME)"
fi

pkill -RTMIN+8 waybar 2>/dev/null || true
