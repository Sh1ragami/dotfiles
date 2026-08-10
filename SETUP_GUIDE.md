# Setup Guide

Step-by-step setup instructions for reproducing this environment on a fresh Arch Linux installation.

## Prerequisites

Ensure Git is installed on your fresh system:

```bash
sudo pacman -Syu --needed git
```

## Setup Steps

### 1. SSH Authentication for GitHub

Generate an SSH key:

```bash
ssh-keygen -t ed25519 -C "your-email@example.com"
```

Display and copy the public key:

```bash
cat ~/.ssh/id_ed25519.pub
```

Add the key to your [GitHub SSH Settings](https://github.com/settings/keys) and verify:

```bash
ssh -T git@github.com
```

### 2. Clone Repository

```bash
git clone git@github.com:<your-username>/dotfiles.git ~/dotfiles
```

### 3. Run Installer

```bash
cd ~/dotfiles
./install.sh
```

The installer will:
- Install `stow`, `base-devel`, and `paru` (if absent).
- Install official packages from `pkglist.txt` and AUR packages from `aurlist.txt`.
- Backup conflicting config files to `*.backup`.
- Symlink configs via GNU Stow.
- Generate a `~/.gitconfig.local` template.

### 4. Post-Setup

Set your default shell to Zsh:

```bash
chsh -s $(which zsh)
```

Configure your local Git identity:

```bash
git config --file ~/.gitconfig.local user.name "Your Name"
git config --file ~/.gitconfig.local user.email "your-email@example.com"
```
