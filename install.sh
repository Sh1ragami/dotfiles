#!/usr/bin/env bash

set -ue

# dotfilesディレクトリのパス
DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Starting dotfiles installation ==="

# 1. 必要なツールのインストール (stow, git, base-devel)
echo "Installing prerequisites (stow, git, base-devel)..."
sudo pacman -S --needed --noconfirm stow git base-devel

# 2. AURヘルパー (paru) のインストール
if ! command -v paru &> /dev/null && ! command -v yay &> /dev/null; then
    echo "AUR helper not found. Installing paru-bin..."
    git clone https://aur.archlinux.org/paru-bin.git /tmp/paru-bin
    (cd /tmp/paru-bin && makepkg -si --noconfirm)
    rm -rf /tmp/paru-bin
fi

AUR_HELPER=""
if command -v paru &> /dev/null; then
    AUR_HELPER="paru"
elif command -v yay &> /dev/null; then
    AUR_HELPER="yay"
fi

# 3. パッケージのインストール
if [ -f "$DOTFILES_DIR/pkglist.txt" ]; then
    echo "Installing official packages from pkglist.txt..."
    sudo pacman -S --needed --noconfirm - < "$DOTFILES_DIR/pkglist.txt"
fi

if [ -f "$DOTFILES_DIR/aurlist.txt" ] && [ -n "$AUR_HELPER" ]; then
    echo "Installing AUR packages from aurlist.txt using $AUR_HELPER..."
    $AUR_HELPER -S --needed --noconfirm - < "$DOTFILES_DIR/aurlist.txt"
fi

# 4. 競合する既存ファイルの退避とStowの適用
stow_dirs=(zsh git config)

echo "Applying GNU Stow..."
for dir in "${stow_dirs[@]}"; do
    echo "Applying package: $dir"
    
    # 事前チェック：競合するファイルがあるか確認
    # stow -n (no-action) でシミュレーションし、警告文から競合ファイルを特定する
    conflicts=$(stow -n -d "$DOTFILES_DIR" -t "$HOME" "$dir" 2>&1 | grep "existing target is not a symlink" || true)
    
    if [ -n "$conflicts" ]; then
        echo "Found conflicts. Backing up existing files..."
        echo "$conflicts" | while read -r line; do
            # 競合パスの抽出 (例: WARNING: in target of zsh: existing target is not a symlink: .zshrc)
            rel_path=$(echo "$line" | sed -E 's/.*existing target is not a symlink: (.*)/\1/')
            if [ -n "$rel_path" ] && [ -e "$HOME/$rel_path" ] && [ ! -L "$HOME/$rel_path" ]; then
                echo "  Backup: $HOME/$rel_path -> $HOME/${rel_path}.backup"
                mv "$HOME/$rel_path" "$HOME/${rel_path}.backup"
            fi
        done
    fi
    
    # 実際にシンボリックリンクを展開
    stow -d "$DOTFILES_DIR" -t "$HOME" "$dir"
done

# 5. Git 個人設定テンプレート (~/.gitconfig.local) の作成
if [ ! -f "$HOME/.gitconfig.local" ]; then
    echo "Creating template ~/.gitconfig.local..."
    cat << 'EOF' > "$HOME/.gitconfig.local"
[user]
	name = Your Name
	email = your-email@example.com
EOF
    echo "  -> Created ~/.gitconfig.local. Please edit it with your own name and email!"
fi

# 6. ダウンロード自動整理タイマーの有効化
echo "Enabling organize-downloads timer..."
systemctl --user daemon-reload
systemctl --user enable --now organize-downloads.timer 2>/dev/null || true

# 7. Google Drive 連携と自動バックアップの設定
echo ""
echo "=== Google Drive & Backup Setup ==="
if command -v rclone &> /dev/null && rclone listremotes 2>/dev/null | grep -q '^gdrive:'; then
    echo "Google Drive remote 'gdrive' is already configured."
    echo "Enabling Google Drive mount & backup services..."
    systemctl --user enable --now rclone-mount.service 2>/dev/null || true
    systemctl --user enable --now rclone-sync.timer 2>/dev/null || true
    echo "  -> Google Drive mount & backup services are active!"
else
    echo "Google Drive 連携 ('gdrive') がまだ設定されていません。"
    echo ""
    echo "【セットアップの流れ】"
    echo "  1. リモート名: 'gdrive' と入力"
    echo "  2. ストレージタイプ: 'drive' (Google Drive) を選択"
    echo "  3. ブラウザが開いたら Google アカウントでログイン・許可"
    echo ""
    setup_gdrive="Y"
    read -rp "今すぐ Google Drive を設定しますか？ [Y/n]: " setup_gdrive || true
    setup_gdrive="${setup_gdrive:-Y}"
    if [[ "$setup_gdrive" =~ ^[Yy]$ ]]; then
        rclone config
        if rclone listremotes 2>/dev/null | grep -q '^gdrive:'; then
            echo ""
            echo "Google Drive の設定が完了しました！サービスを有効化します..."
            systemctl --user daemon-reload
            systemctl --user enable --now rclone-mount.service 2>/dev/null || true
            systemctl --user enable --now rclone-sync.timer 2>/dev/null || true
            echo "  -> Google Drive のマウント (~/GoogleDrive) と自動バックアップが有効になりました！"
        else
            echo "Google Drive ('gdrive') が作成されませんでした。"
            echo "後で設定する場合は以下のコマンドを実行してください："
            echo "  rclone config"
            echo "  systemctl --user enable --now rclone-mount.service rclone-sync.timer"
        fi
    else
        echo "Google Drive セットアップをスキップしました。"
        echo "後で設定する場合は以下のコマンドを実行してください："
        echo "  rclone config"
        echo "  systemctl --user enable --now rclone-mount.service rclone-sync.timer"
    fi
fi

echo ""
echo "=== Dotfiles installation completed successfully! ==="

