#!/bin/bash

# Alt+E でこれを叩くだけ。余計な判定はすべて捨てます。
if pgrep -f "kitty --class yazi-float" >/dev/null; then
  pkill -f "kitty --class yazi-float"
else
  # 起動するだけ。中身の挙動は yazi.toml の [opener] に任せる
  kitty --class yazi-float yazi
fi
