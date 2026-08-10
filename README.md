# dotfiles

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

| ステップ | コマンド / 操作 |
| --- | --- |
| **1. SSH鍵の準備** | `ssh-keygen -t ed25519 -C "your-email@example.com"`<br>`cat ~/.ssh/id_ed25519.pub`<br>`ssh -T git@github.com` |
| **2. クローンとインストール** | `git clone git@github.com:<your-username>/dotfiles.git ~/dotfiles`<br>`cd ~/dotfiles && ./install.sh` |
| **3. 初期設定** | `chsh -s $(which zsh)`<br>`git config --file ~/.gitconfig.local user.name "Your Name"`<br>`git config --file ~/.gitconfig.local user.email "your-email@example.com"` |

## パッケージ更新

```bash
pacman -Qqen > ~/dotfiles/pkglist.txt
pacman -Qqem > ~/dotfiles/aurlist.txt
```

## License

[MIT](LICENSE)
