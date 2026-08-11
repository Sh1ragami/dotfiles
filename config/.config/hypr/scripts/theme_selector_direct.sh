#!/usr/bin/env bash

# 引数からテーマを取得
theme="$1"

if [[ -z "$theme" ]]; then
    exit 1
fi

# 現在のテーマを記録
echo "$theme" > /tmp/current_theme.txt

# 1. 壁紙の更新を最優先でコピー
cp "$HOME/dotfiles/themes/$theme/hypr/wallpaper.png" "$HOME/.config/hypr/wallpaper.png" 2>/dev/null || true

# 2. 壁紙 (GTK Layer Shell デーモン) へ即時ソケット通知 (遅延なし即時描画)
python3 -c '
import socket, os, subprocess
sock = "/tmp/hypr_wallpaper.sock"
if os.path.exists(sock):
    try:
        s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        s.connect(sock)
        s.sendall(b"reload")
        s.close()
    except Exception:
        pass
else:
    subprocess.Popen(["python3", os.path.expanduser("~/.config/hypr/scripts/wallpaper_daemon.py")])
' 2>/dev/null || true

# 3. その他の設定ファイルの上書き
cp "$HOME/dotfiles/themes/$theme/waybar/style.css" "$HOME/.config/waybar/style.css" 2>/dev/null || true
cp "$HOME/dotfiles/themes/$theme/wofi/style.css" "$HOME/.config/wofi/style.css" 2>/dev/null || true
cp "$HOME/dotfiles/themes/$theme/kitty/theme.conf" "$HOME/.config/kitty/theme.conf" 2>/dev/null || true
cp "$HOME/dotfiles/themes/$theme/kitty/opacity.conf" "$HOME/.config/kitty/opacity.conf" 2>/dev/null || true
cp "$HOME/dotfiles/themes/$theme/hypr/theme.conf" "$HOME/.config/hypr/theme.conf" 2>/dev/null || true
cp "$HOME/dotfiles/themes/$theme/swaync/style.css" "$HOME/.config/swaync/style.css" 2>/dev/null || true
cp "$HOME/dotfiles/themes/$theme/zathura/zathurarc" "$HOME/.config/zathura/zathurarc" 2>/dev/null || true
cp "$HOME/dotfiles/themes/$theme/nvim/lualine.lua" "$HOME/.config/nvim/lua/plugins/lualine.lua" 2>/dev/null || true
cp "$HOME/dotfiles/themes/$theme/nvim/options.lua" "$HOME/.config/nvim/lua/config/options.lua" 2>/dev/null || true

# 4. Waybar & SwayNC & Kitty の即時シグナル・カラーパレットリロード
pkill -SIGUSR2 waybar 2>/dev/null || true
swaync-client -R 2>/dev/null || true
swaync-client -rs 2>/dev/null || true
pkill -USR1 kitty 2>/dev/null || true
kitty @ set-colors -a -c "$HOME/.config/kitty/theme.conf" 2>/dev/null || true

# 5. Hyprland の設定リロード
hyprctl reload 2>/dev/null || true
