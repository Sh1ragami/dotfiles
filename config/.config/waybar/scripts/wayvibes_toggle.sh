#!/bin/bash

if pgrep -x "wayvibes" >/dev/null; then
  pkill wayvibes
else
  PIPEWIRE_LATENCY="32/48000" wayvibes ~/.local/share/soundpacks/nk-cream -v 2.5 -bg
fi

pkill -RTMIN+8 waybar
