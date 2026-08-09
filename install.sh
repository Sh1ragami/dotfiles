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
stow_dirs=(zsh tmux git config)

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

echo "=== Dotfiles installation completed successfully! ==="
