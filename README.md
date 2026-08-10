# dotfiles

GNU Stow で管理された Arch Linux 用の dotfiles リポジトリです。Hyprland と Neovim を中心としたキーボード駆動の環境を構築します。

## 構成要素

| カテゴリ | ツール |
| --- | --- |
| **OS** | Arch Linux |
| **ウィンドウマネージャー** | Hyprland (Wayland) |
| **エディタ** | Neovim |
| **ターミナル** | Kitty |
| **シェル** | Zsh (Starship, zoxide, mise) |
| **PDFビューア** | Zathura |
| **バー** | Waybar |
| **ランチャー** | Wofi |

## 主な機能

- **フローティング Gemini (スクラッチパッド)**: `$mainMod + Space` で常駐型 Gemini ウィンドウを即座に表示・非表示。
- **Neovim ↔ Zathura SyncTeX 連動**: カーソル静止位置に合わせた PDF 自動スクロール追従。
- **Stow 管理**: `install.sh` によるパッケージ一括導入と設定シンボリックリンク展開。

## インストール

```bash
git clone https://github.com/Sh1ragami/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

### インストール後の設定

各環境の Git 個人情報を設定してください：

```bash
git config --file ~/.gitconfig.local user.name "Your Name"
git config --file ~/.gitconfig.local user.email "your-email@example.com"
```

## 主なキーバインド

| ショートカット | 機能 |
| --- | --- |
| `$mainMod + Space` | フローティング Gemini の表示 / 非表示 |
| `$mainMod + G` | タイル型 Gemini の起動 |
| `$mainMod + T` | ターミナルの起動 |
| `$mainMod + E` | ファイルマネージャーの起動 |
| `$mainMod + V` | フローティング表示のトグル |
| `$mainMod + Q` | ウィンドウを閉じる |

## メンテナンス

インストール済みパッケージリストの更新：

```bash
pacman -Qqen > ~/dotfiles/pkglist.txt
pacman -Qqem > ~/dotfiles/aurlist.txt
```
