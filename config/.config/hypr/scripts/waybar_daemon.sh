#!/usr/bin/env bash

# Waybar 永続化・自動復元保護デーモン
while true; do
    if ! pgrep -x "waybar" > /dev/null; then
        waybar -c "$HOME/.config/waybar/config_top.jsonc" -s "$HOME/.config/waybar/style.css" >/dev/null 2>&1 &
    fi
    sleep 2
done
