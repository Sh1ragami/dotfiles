#!/usr/bin/env bash

CLASS="btop-float"

if pgrep -f "kitty --class $CLASS" >/dev/null; then
    pkill -f "kitty --class $CLASS"
else
    kitty --class "$CLASS" -o confirm_os_window_close=0 -e btop &
fi
