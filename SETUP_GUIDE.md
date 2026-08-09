# 新環境セットアップ指示書（Arch Linux再現マニュアル）

新しい端末（あるいは初期化したPC）で、現在の Arch Linux 環境（Hyprland + Zellij + Neovim 等）を 1 から再現するための手順書です。

---

## 📋 全体の流れ
1. **システム基本ツールの準備**
2. **GitHub 用の SSH 接続設定**
3. **dotfiles リポジトリの取得**
4. **セットアップスクリプトの実行**
5. **後処理と各種ツールの動作確認**

---

## 🛠️ ステップバイステップ手順

### Step 1: システム基本ツールの準備
新しくインストールした Arch Linux にログインし、Git がインストールされていることを確認します。

```bash
# パッケージデータベースの同期と git のインストール
sudo pacman -Syu --needed git
```

---

### Step 2: GitHub 用の SSH 接続設定
セキュリティのため、秘密鍵は dotfiles に含めていません。新端末で新しく鍵を作成して GitHub に登録します。

#### 1. SSH 鍵の生成
```bash
ssh-keygen -t ed25519 -C "your-email@example.com"
```
*※ 全て `Enter` を押してデフォルトのまま進めてください。*

#### 2. 公開鍵の確認
```bash
cat ~/.ssh/id_ed25519.pub
```
画面に表示された `ssh-ed25519 AAAA...` で始まる文字列をすべてコピーします。

#### 3. GitHub への登録
1. ブラウザで [GitHub Settings (SSH keys)](https://github.com/settings/keys) を開きます。
2. **New SSH key** をクリックします。
3. **Title** に新しいマシンの名前（例: `arch-laptop`）を入力し、**Key** にコピーした公開鍵を貼り付けて保存します。

#### 4. 接続テスト
以下のコマンドを実行し、GitHub への接続を確認します。
```bash
ssh -T git@github.com
```
`Hi Sh1ragami! You've successfully authenticated...` と表示されれば成功です。

---

### Step 3: dotfiles リポジトリのクローン
GitHub から dotfiles を SSH 経由でクローンします。

```bash
git clone git@github.com:Sh1ragami/dotfiles.git ~/dotfiles
```
*(※ リポジトリ名が異なる場合は、実際のパスに変更してください)*

---

### Step 4: セットアップスクリプトの実行
クローンしたディレクトリに入り、自動インストールスクリプトを実行します。

```bash
cd ~/dotfiles
./install.sh
```

**【このスクリプトが自動で行う処理】**:
- パッケージ管理の土台（`stow`, `base-devel`）をインストール
- AURヘルパー `paru` の自動セットアップ
- [pkglist.txt](file:///home/sh1ragami/dotfiles/pkglist.txt) / [aurlist.txt](file:///home/sh1ragami/dotfiles/aurlist.txt) から必要なツール（Hyprland, Neovim, Firefox等）を一括インストール
- ホームディレクトリ直下にある既存の同名設定ファイルを自動バックアップ（`.backup` を付与して退避）
- GNU Stow による設定シンボリックリンクの適用

---

### Step 5: 後処理とツールの確認

#### 1. デフォルトシェルを zsh に変更
インストール完了後、デフォルトのシェルを zsh に変更してログインし直します。
```bash
chsh -s $(which zsh)
```
*(※ 反映のために、一度システムをログアウトして再ログインしてください)*

#### 2. アプリケーションの個別復元 (PWAなど)
* **`manabie-learner` や `Outlook` などのWebアプリ**:
  1. インストールされた Google Chrome を起動します。
  2. 対象のWebサイトにアクセスし、Chromeのメニュー（右上の `︙`） ＞ **「保存して共有」 ＞ 「アプリとしてインストール」** を実行してデスクトップに配置します。

#### 3. 動作テスト
各ツールが正しく起動するか確認します。
* `hyprland` (Hyprland デスクトップ環境の立ち上げ)
* `nvim` (Neovimエディタ)
* `zellij` (ターミナルマルチプレクサ)
* `yazi` (ファイルマネージャー)
