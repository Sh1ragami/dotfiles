#!/usr/bin/env bash

# Google Drive 自動同期スクリプト (Documents & Pictures)
set -euo pipefail

LOG_DIR="$HOME/.local/state/rclone"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/sync.log"

# gdrive リモートが設定されているか確認
if ! rclone listremotes 2>/dev/null | grep -q '^gdrive:'; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Google Drive remote 'gdrive' is not configured yet. Run 'rclone config' to set up." >> "$LOG_FILE"
    exit 0
fi

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting Google Drive backup (sync with version history)..." >> "$LOG_FILE"

TODAY=$(date '+%Y-%m-%d')

# 1. Documents の同期 (変更・削除されたファイルは History/Documents/YYYY-MM-DD に自動退避)
if [ -d "$HOME/Documents" ]; then
    rclone sync "$HOME/Documents" "gdrive:Backup/Documents" \
        --backup-dir "gdrive:Backup/History/Documents/$TODAY" \
        --fast-list \
        --exclude ".git/**" \
        --exclude "node_modules/**" \
        --exclude "__pycache__/**" \
        --exclude "*.tmp" \
        --log-file "$LOG_FILE" \
        --log-level NOTICE || true
fi

# 2. Pictures の同期 (変更・削除されたファイルは History/Pictures/YYYY-MM-DD に自動退避)
if [ -d "$HOME/Pictures" ]; then
    rclone sync "$HOME/Pictures" "gdrive:Backup/Pictures" \
        --backup-dir "gdrive:Backup/History/Pictures/$TODAY" \
        --fast-list \
        --log-file "$LOG_FILE" \
        --log-level NOTICE || true
fi

# 3. Music の同期 (変更・削除されたファイルは History/Music/YYYY-MM-DD に自動退避)
if [ -d "$HOME/Music" ]; then
    rclone sync "$HOME/Music" "gdrive:Backup/Music" \
        --backup-dir "gdrive:Backup/History/Music/$TODAY" \
        --fast-list \
        --log-file "$LOG_FILE" \
        --log-level NOTICE || true
fi

# 4. Videos の同期 (変更・削除されたファイルは History/Videos/YYYY-MM-DD に自動退避)
if [ -d "$HOME/Videos" ]; then
    rclone sync "$HOME/Videos" "gdrive:Backup/Videos" \
        --backup-dir "gdrive:Backup/History/Videos/$TODAY" \
        --fast-list \
        --log-file "$LOG_FILE" \
        --log-level NOTICE || true
fi

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Google Drive backup finished successfully." >> "$LOG_FILE"
