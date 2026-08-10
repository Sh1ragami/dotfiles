#!/usr/bin/env bash

uptime_str=$(uptime -p | sed 's/up //' | sed 's/ hours\?,/h/' | sed 's/ minutes\?/m/' | sed 's/ hour\?,/h/' | sed 's/ minute\?/m/')
echo "{\"text\": \"<span font='13' weight='bold' foreground='#d8a657'>󰌽  sh1ragami</span>    <span font='10' foreground='#a89984'>󰅐 Uptime: $uptime_str</span>\"}"
