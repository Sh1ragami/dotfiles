#!/bin/bash

# 画面共有・ポータルサービスの確実なリセット・スタートスクリプト
sleep 1
killall -9 xdg-desktop-portal-hyprland xdg-desktop-portal-gtk xdg-desktop-portal 2>/dev/null || true

export XDG_CURRENT_DESKTOP=Hyprland

# 環境変数の DBus / systemd 登録
dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP

if [ -f /usr/lib/xdg-desktop-portal-hyprland ]; then
    /usr/lib/xdg-desktop-portal-hyprland &
elif [ -f /usr/libexec/xdg-desktop-portal-hyprland ]; then
    /usr/libexec/xdg-desktop-portal-hyprland &
fi

sleep 0.5

if [ -f /usr/lib/xdg-desktop-portal ]; then
    /usr/lib/xdg-desktop-portal &
elif [ -f /usr/libexec/xdg-desktop-portal ]; then
    /usr/libexec/xdg-desktop-portal &
fi
