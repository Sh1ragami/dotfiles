#!/usr/bin/env bash

target_page="$1"
if [ -n "$target_page" ]; then
    echo "$target_page" > /tmp/swaync_page.txt
fi

swaync-client -R -rs || true
