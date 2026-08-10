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

## パッケージ更新

```bash
pacman -Qqen > ~/dotfiles/pkglist.txt
pacman -Qqem > ~/dotfiles/aurlist.txt
```

## License

[MIT](LICENSE)
