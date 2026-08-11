#!/bin/bash

# SwayNC の DND 状態を取得してアイコンを動的に変更
if [ "$(swaync-client -D 2>/dev/null)" = "true" ]; then
    ICON="" # 消音マーク (DND Active)
else
    ICON="" # 通常通知マーク
fi

TIME=$(date "+%H:%M")
DATE=$(date "+%-m月%-d日")

echo "{\"text\": \"$ICON  $TIME  |    $DATE\"}"
