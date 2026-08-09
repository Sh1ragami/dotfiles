#!/usr/bin/env bash

# Uptime文字列の整形 (例: up 1 hour, 30 minutes -> 1h 30m)
uptime_str=$(uptime -p | sed 's/up //' | sed 's/ hours\?,/h/' | sed 's/ minutes\?/m/' | sed 's/ hour\?,/h/' | sed 's/ minute\?/m/')

# JSON形式でSwayNCへ出力
echo "{\"text\": \"<span font='13' weight='bold'>sh1ragami</span>\n<span font='9' fgcolor='#928374'>Uptime: $uptime_str</span>\"}"
