#!/usr/bin/env bash
set -euo pipefail

# GTK ネイティブダイアログを優先起動
if command -v python3 &>/dev/null; then
    exec /home/sh1ragami/.local/bin/photos_vault_gui.py "$@"
fi
