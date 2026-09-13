#!/bin/bash

# AGS が起動していない場合は自動起動
if ! pgrep -f "gjs.*ags" >/dev/null && ! pgrep -x "ags" >/dev/null; then
    hyprctl dispatch exec "ags run"
    sleep 0.6
fi

ags request "toggle" 2>/dev/null || ags toggle control-center 2>/dev/null
