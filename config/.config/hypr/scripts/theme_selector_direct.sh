#!/usr/bin/env bash

# 引数からテーマを取得
theme="$1"

if [[ -z "$theme" ]]; then
    exit 1
fi

# 設定ファイルの上書き（Stowのシンボリックリンク経由で実体も更新されます）
cp "$HOME/dotfiles/themes/$theme/waybar/style.css" "$HOME/.config/waybar/style.css" 2>/dev/null || true
cp "$HOME/dotfiles/themes/$theme/wofi/style.css" "$HOME/.config/wofi/style.css" 2>/dev/null || true
cp "$HOME/dotfiles/themes/$theme/kitty/theme.conf" "$HOME/.config/kitty/theme.conf" 2>/dev/null || true
cp "$HOME/dotfiles/themes/$theme/kitty/opacity.conf" "$HOME/.config/kitty/opacity.conf" 2>/dev/null || true
cp "$HOME/dotfiles/themes/$theme/hypr/theme.conf" "$HOME/.config/hypr/theme.conf" 2>/dev/null || true
cp "$HOME/dotfiles/themes/$theme/swaync/style.css" "$HOME/.config/swaync/style.css" 2>/dev/null || true
cp "$HOME/dotfiles/themes/$theme/zathura/zathurarc" "$HOME/.config/zathura/zathurarc" 2>/dev/null || true
cp "$HOME/dotfiles/themes/$theme/nvim/lualine.lua" "$HOME/.config/nvim/lua/plugins/lualine.lua" 2>/dev/null || true
cp "$HOME/dotfiles/themes/$theme/nvim/options.lua" "$HOME/.config/nvim/lua/config/options.lua" 2>/dev/null || true
cp "$HOME/dotfiles/themes/$theme/hypr/wallpaper.png" "$HOME/.config/hypr/wallpaper.png" 2>/dev/null || true

# 壁紙の動的リロード
hyprctl hyprpaper unload all || true
hyprctl hyprpaper preload "$HOME/.config/hypr/wallpaper.png" || true
hyprctl hyprpaper wallpaper ",$HOME/.config/hypr/wallpaper.png" || true

# デスクトップ環境のリロード（まず基本設定を読み込む）
hyprctl reload || true

# リロード後にテーマ固有の gaps / borders / shadow / opacity を適用
if [[ "$theme" == "study" ]]; then
    # 📚 学習用テーマ：囲い線なし(border_size 0)・隙間ゼロ・ベタ塗り・文字視認性＆作業効率最重視
    kitty @ set-background-opacity 1.0 2>/dev/null || true
    hyprctl keyword decoration:blur:enabled false
    hyprctl keyword decoration:active_opacity 1.0
    hyprctl keyword decoration:inactive_opacity 1.0
    hyprctl keyword decoration:dim_inactive false
    hyprctl keyword general:gaps_in 0
    hyprctl keyword general:gaps_out 0
    hyprctl keyword general:border_size 0
    hyprctl keyword general:col.active_border "rgba(282a3aff)"
    hyprctl keyword general:col.inactive_border "rgba(282a3aff)"
    hyprctl keyword decoration:rounding 0
    hyprctl keyword decoration:shadow:enabled false
else
    # 🎨 通常テーマ(夕暮れ/星空/東京夜)：極細(1px)の洗練グラデーションボーダー・角丸12px・すりガラス
    kitty @ set-background-opacity 0.85 2>/dev/null || true
    hyprctl keyword decoration:blur:enabled true
    hyprctl keyword decoration:blur:size 8
    hyprctl keyword decoration:blur:passes 4
    hyprctl keyword decoration:active_opacity 0.93
    hyprctl keyword decoration:inactive_opacity 0.85
    hyprctl keyword decoration:dim_inactive false
    hyprctl keyword general:gaps_in 6
    hyprctl keyword general:gaps_out 12
    hyprctl keyword general:border_size 1
    hyprctl keyword general:col.active_border "rgba(7aa2f7ff) rgba(bb9af7ff) 45deg"
    hyprctl keyword general:col.inactive_border "rgba(1f233566)"
    hyprctl keyword decoration:rounding 12
    hyprctl keyword decoration:shadow:enabled true
    hyprctl keyword decoration:shadow:range 25
    hyprctl keyword decoration:shadow:render_power 4
fi

pkill waybar || true
hyprctl dispatch exec waybar
swaync-client -R || true
swaync-client -rs || true

# 起動中のKittyに設定再読み込みのシグナルを送信
pkill -USR1 kitty || true

# SwayNCの通知として完了を知らせる
notify-send "Theme Changed" "Successfully applied $theme theme!"
