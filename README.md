# dotfiles

Hyprland + Neovim 向けの環境設定。GNU Stow で管理。

## 概要

- **WM**: Hyprland (Wayland)
- **Terminal**: Kitty
- **Shell**: Zsh (Starship)
- **Editor**: Neovim (LazyVim)
- **PDF Viewer**: Zathura
- **Bar**: Waybar

## 構成・動作

- **Gemini (Scratchpad)**: `$mainMod + Space` で常駐型 Gemini ウィンドウをトグル表示（Hyprland Special Workspace）。
- **Neovim & Zathura**: SyncTeX によるカーソル自動連動スクロール（ハイライト透明化処理済み）。

## セットアップ

### 1. SSH鍵の準備

```bash
ssh-keygen -t ed25519 -C "your-email@example.com"
cat ~/.ssh/id_ed25519.pub
# 公開鍵を GitHub に登録後、接続確認
ssh -T git@github.com
```

### 2. クローンとインストール

```bash
git clone git@github.com:<your-username>/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

`install.sh` はパッケージ導入、既存設定のバックアップ (`*.backup`)、Stow によるシンボリックリンク作成を自動で行います。

### 3. 個別設定

シェル変更と Git ローカル情報の設定：

```bash
chsh -s $(which zsh)

git config --file ~/.gitconfig.local user.name "Your Name"
git config --file ~/.gitconfig.local user.email "your-email@example.com"
```

## キーバインド

- `$mainMod + Space`: フローティング Gemini トグル
- `$mainMod + G`: タイル型 Gemini 起動
- `$mainMod + T`: ターミナル起動
- `$mainMod + E`: ファイルマネージャー起動
- `$mainMod + V`: フローティングトグル
- `$mainMod + Q`: ウィンドウ閉じる

## パッケージ更新

```bash
pacman -Qqen > ~/dotfiles/pkglist.txt
pacman -Qqem > ~/dotfiles/aurlist.txt
```
