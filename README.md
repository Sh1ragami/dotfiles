# dotfiles

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/9ecf1680-116d-4603-88a0-99db409cad0b" />


Hyprland + Neovim 向けの環境設定。GNU Stow で管理。

## 概要

| カテゴリ | ツール |
| --- | --- |
| **WM** | Hyprland (Wayland) |
| **Terminal** | Kitty |
| **Shell** | Zsh (Starship) |
| **Editor** | Neovim |
| **PDF Viewer** | Zathura |
| **Bar** | Waybar |
| **Notifications** | SwayNC (Modern Floating & Screenshot Widget) |
| **Cloud Backup** | RClone (Google Drive Mount & Version-History Sync) |
| **File Automation**| organize-tool (Downloads monthly auto-sorting) |

## セットアップ

### 1. SSH鍵の準備

```bash
ssh-keygen -t ed25519 -C "your-email@example.com"
cat ~/.ssh/id_ed25519.pub
ssh -T git@github.com
```

### 2. クローンとインストール

```bash
git clone git@github.com:<your-username>/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

### 3. 初期設定

```bash
chsh -s $(which zsh)

git config --file ~/.gitconfig.local user.name "Your Name"
git config --file ~/.gitconfig.local user.email "your-email@example.com"
```

### 4. Google Drive 連携 & 自動化サービス (任意)

Google Drive のマウントおよび Documents/Pictures/Music/Videos の自動バックアップ、Downloads の自動整理を有効化します：

```bash
# 1. Google Drive の初期認証 (リモート名を 'gdrive' に設定)
rclone config

# 2. 自動起動サービス・タイマーの有効化
systemctl --user daemon-reload
systemctl --user enable --now rclone-mount.service
systemctl --user enable --now rclone-sync.timer
systemctl --user enable --now organize-downloads.timer
```

* **マウント先**: `~/GoogleDrive` (Thunar サイドバーから直接アクセス可能)
* **バックアップ方式**: `--backup-dir` による世代管理（PCで削除したファイルも `Backup/History/` に日付別退避）
* **機密情報について**: OAuth トークンや認証情報は `~/.config/rclone/rclone.conf` に安全にローカル保存され、リポジトリにはコミットされません。


## パッケージ更新

```bash
pacman -Qqen > ~/dotfiles/pkglist.txt
pacman -Qqem > ~/dotfiles/aurlist.txt
```

## License

[MIT](LICENSE)
