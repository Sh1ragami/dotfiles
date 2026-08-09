# My Dotfiles for Arch Linux

Arch Linux (Hyprland + Wayland) のデスクトップ環境を再現するための dotfiles リポジトリです。
**GNU Stow** を用いて設定ファイルを管理し、パッケージリストのインポート・エクスポートを自動化しています。

---

## 🛠️ インストール方法 (新しい端末での再現手順)

新しい Arch Linux 環境を構築する際、以下のコマンドを実行するだけで必要なパッケージのインストールから設定の適用まで自動で行われます。

```bash
# 1. リポジトリをクローン
git clone <YOUR_REPOSITORY_URL> ~/dotfiles

# 2. クローン先に移動してインストールスクリプトを実行
cd ~/dotfiles
./install.sh
```

### `install.sh` が行うこと:
1. `stow`, `git`, `base-devel` の自動インストール
2. AURヘルパー `paru` がなければ自動ビルド＆インストール
3. `pkglist.txt` を用いた公式パッケージの一括インストール
4. `aurlist.txt` を用いたAURパッケージの一括インストール
5. 既存設定ファイルのバックアップ自動作成（`.backup` サフィックスを付与）
6. GNU Stow によるシンボリックリンクの適用

---

## 💡 日常の管理方法

### 1. 設定の変更を保存する
ホームディレクトリ内の設定ファイル（例: `~/.zshrc` や `~/.config/hypr/hyprland.conf` など）は、すでに `~/dotfiles` 内の実体ファイルへのシンボリックリンクになっています。
そのため、普段通りファイルを編集したあとに Git でコミット & プッシュするだけで変更を保存できます。

```bash
cd ~/dotfiles
git add .
git commit -m "update: config change"
git push
```

### 2. パッケージリストを更新する
新しいパッケージをインストールした、あるいは不要なパッケージを削除した場合は、以下のコマンドでリストを更新してコミットしてください。

```bash
# 公式パッケージとAURパッケージを切り分けて出力
pacman -Qqen > ~/dotfiles/pkglist.txt
pacman -Qqem > ~/dotfiles/aurlist.txt
```

### 3. 新しい設定ファイル/ディレクトリを管理対象に追加する
新しく作成したツール（例: `example-tool`）の設定を管理したい場合は、以下の手順で行います。

```bash
# 1. dotfiles 配下にディレクトリを作成
mkdir -p ~/dotfiles/example-tool/.config

# 2. 設定ファイルを dotfiles 配下に移動
mv ~/.config/example-tool ~/dotfiles/example-tool/.config/

# 3. Stowでシンボリックリンクを作成
cd ~/dotfiles
stow example-tool
```

---

## 🖥️ 環境構成

本ドキュメント作成時点で再現される主なデスクトップ環境の構成要素です。

| カテゴリ | ツール名 |
| :--- | :--- |
| **OS** | Arch Linux |
| **ディスプレイプロトコル** | Wayland |
| **ディスプレイマネージャー** | ly |
| **ウィンドウマネージャー** | Hyprland |
| **ステータスバー** | Waybar |
| **ランチャー** | Wofi |
| **ターミナル / TUI** | Kitty, tmux, yazi, lazygit, lazydocker, btop |
| **シェル** | zsh (starship, zsh-autosuggestions, zsh-syntax-highlighting) |
| **入力メソッド** | fcitx5 (fcitx5-mozc) |
| **その他ユーティリティ** | swaybg, wlogout, swaync, vibes, hyprshot, wl-clipboard, brightnessctl, batsignal |
| **CLIツール** | eza, bat, fd, ripgrep, fzf, gh, git, neovim, zoxide, mise |
