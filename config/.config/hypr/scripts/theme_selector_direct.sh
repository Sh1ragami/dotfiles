#!/usr/bin/env bash

# 引数からテーマを取得
theme="$1"

if [[ -z "$theme" ]]; then
    exit 1
fi

# 設定ファイルの上書き（Stowのシンボリックリンク経由で実体も更新されます）
cp "$HOME/dotfiles/themes/$theme/waybar/style.css" "$HOME/.config/waybar/style.css"
cp "$HOME/dotfiles/themes/$theme/wofi/style.css" "$HOME/.config/wofi/style.css"
cp "$HOME/dotfiles/themes/$theme/kitty/theme.conf" "$HOME/.config/kitty/theme.conf"
cp "$HOME/dotfiles/themes/$theme/hypr/theme.conf" "$HOME/.config/hypr/theme.conf"

# デスクトップ環境のリロード
hyprctl reload || true
pkill waybar || true
hyprctl dispatch exec waybar

# 起動中のKittyに設定再読み込みのシグナルを送信
pkill -USR1 kitty || true

# SwayNCの通知として完了を知らせる (サイドバーを開いたままでもあるので、通知を出すか、または静かに完了)
notify-send "Theme Changed" "Successfully applied $theme theme!"
