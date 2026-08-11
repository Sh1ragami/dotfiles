#!/bin/bash

YAZI_CLASS="yazi-float"
TARGET_SPECIAL="special:yazi"

# 1. すでに special:yazi に紛れ込んだ他のウィンドウを現在のワークスペースへ救出
ACTIVE_WS=$(hyprctl activeworkspace -j | jq -r '.id')
hyprctl clients -j | jq -r ".[] | select(.workspace.name == \"$TARGET_SPECIAL\" and .class != \"$YAZI_CLASS\") | .address" | while read -r addr; do
    if [ -n "$addr" ] && [ "$addr" != "null" ]; then
        hyprctl dispatch movetoworkspacesilent "$ACTIVE_WS,address:$addr"
    fi
done

WAS_LAUNCHED=false

# 2. すでに Yazi のウィンドウが存在するか確認
if ! hyprctl clients -j | jq -e ".[] | select(.class == \"$YAZI_CLASS\")" > /dev/null; then
    WAS_LAUNCHED=true
    # 存在しなければバックグラウンド起動
    kitty --class $YAZI_CLASS yazi &
    
    # ウィンドウが識別されるまで待機（最大2秒）
    for i in {1..20}; do
        if hyprctl clients -j | jq -e ".[] | select(.class == \"$YAZI_CLASS\")" > /dev/null; then
            break
        fi
        sleep 0.1
    done
fi

# 3. special:yazi が現在画面上に表示されているか判定
IS_SPECIAL_OPEN=$(hyprctl monitors -j | jq -r ".[] | select(.specialWorkspace.name == \"$TARGET_SPECIAL\") | .specialWorkspace.name")

if [ "$WAS_LAUNCHED" = true ]; then
    # 初回起動時：自動表示されていなければトグルで表示する
    if [ -z "$IS_SPECIAL_OPEN" ]; then
        hyprctl dispatch togglespecialworkspace yazi
    fi
else
    # 2回目以降：すでに表示中なら閉じるときに他ウィンドウが巻き込まれないようフォーカスを合わせる
    if [ -n "$IS_SPECIAL_OPEN" ]; then
        hyprctl dispatch focuswindow "class:^${YAZI_CLASS}$" >/dev/null 2>&1
    fi
    hyprctl dispatch togglespecialworkspace yazi
fi
