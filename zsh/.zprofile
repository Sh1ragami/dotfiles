# Created by `pipx` on 2026-07-18 10:58:38
export PATH="$PATH:/home/sh1ragami/.local/bin"

# tty1 ログイン時に Hyprland を自動起動
if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
    exec /usr/bin/start-hyprland
fi
