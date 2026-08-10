# セットアップガイド

新しい Arch Linux 環境に本環境を再構築する手順です。

## 前提条件

事前に `git` がインストールされていることを確認してください：

```bash
sudo pacman -Syu --needed git
```

## セットアップ手順

### 1. SSH 鍵の作成と GitHub 登録

SSH 鍵を生成します：

```bash
ssh-keygen -t ed25519 -C "your-email@example.com"
```

公開鍵を表示してコピーします：

```bash
cat ~/.ssh/id_ed25519.pub
```

[GitHub SSH Settings](https://github.com/settings/keys) に公開鍵を追加し、接続を確認します：

```bash
ssh -T git@github.com
```

### 2. リポジトリのクローン

```bash
git clone git@github.com:<your-username>/dotfiles.git ~/dotfiles
```

### 3. インストーラーの実行

```bash
cd ~/dotfiles
./install.sh
```

`install.sh` が行う自動処理：
- `stow`, `base-devel`, `paru` のセットアップ
- `pkglist.txt` および `aurlist.txt` からのパッケージ一括導入
- 既存の同名設定ファイルの自動退避 (`*.backup`)
- GNU Stow によるシンボリックリンク適用
- `~/.gitconfig.local` テンプレートの生成

### 4. インストール後の設定

デフォルトシェルを Zsh に変更：

```bash
chsh -s $(which zsh)
```

Git の個人情報を設定：

```bash
git config --file ~/.gitconfig.local user.name "Your Name"
git config --file ~/.gitconfig.local user.email "your-email@example.com"
```
