#!/bin/bash

THUNAR_CLASS="thunar"
TARGET_SPECIAL="special:thunar"

# 1. すでに special:thunar に紛れ込んだ他のウィンドウを現在のワークスペースへ救出 (ただし関連ツール file-roller, loupe 等は維持)
ACTIVE_WS=$(hyprctl activeworkspace -j | jq -r '.id')
hyprctl clients -j | jq -r ".[] | select(.workspace.name == \"$TARGET_SPECIAL\" and .class != \"$THUNAR_CLASS\" and .class != \"file-roller\" and .class != \"org.gnome.FileRoller\" and .class != \"loupe\" and .class != \"org.gnome.Loupe\") | .address" | while read -r addr; do
    if [ -n "$addr" ] && [ "$addr" != "null" ]; then
        hyprctl dispatch movetoworkspacesilent "$ACTIVE_WS,address:$addr"
    fi
done

WAS_LAUNCHED=false

# 2. すでに Thunar のウィンドウが存在するか確認
if ! hyprctl clients -j | jq -e ".[] | select(.class == \"$THUNAR_CLASS\")" > /dev/null; then
    WAS_LAUNCHED=true
    # 存在しなければバックグラウンド起動
    thunar &
    
    # ウィンドウが識別されるまで待機（最大2秒）
    for i in {1..20}; do
        if hyprctl clients -j | jq -e ".[] | select(.class == \"$THUNAR_CLASS\")" > /dev/null; then
            break
        fi
        sleep 0.1
    done
fi

# 3. special:thunar が現在画面上に表示されているか判定
IS_SPECIAL_OPEN=$(hyprctl monitors -j | jq -r ".[] | select(.specialWorkspace.name == \"$TARGET_SPECIAL\") | .specialWorkspace.name")

if [ "$WAS_LAUNCHED" = true ]; then
    # 初回起動時：自動表示されていなければトグルで表示する
    if [ -z "$IS_SPECIAL_OPEN" ]; then
        hyprctl dispatch togglespecialworkspace thunar
    fi
else
    # 2回目以降：すでに表示中なら閉じるときに他ウィンドウが巻き込まれないようフォーカスを合わせる
    if [ -n "$IS_SPECIAL_OPEN" ]; then
        hyprctl dispatch focuswindow "class:^${THUNAR_CLASS}$" >/dev/null 2>&1
        # Thunar 収納時にスマホ写真を自動ロック
        if mountpoint -q "$HOME/スマホ写真"; then
            fusermount3 -u -z "$HOME/スマホ写真" 2>/dev/null || true
            pkill -f "rclone mount gdrive:スマホ写真" 2>/dev/null || true
            chmod 000 "$HOME/スマホ写真" 2>/dev/null || true
            thunar -q 2>/dev/null || true
            notify-send -i security-high "スマホ写真" "🔒 Thunar収納に伴い自動ロックしました" &
        fi
    fi
    hyprctl dispatch togglespecialworkspace thunar
fi
