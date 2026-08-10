# dotfiles

Arch Linux dotfiles managed with GNU Stow. Designed for a keyboard-driven workflow using Hyprland and Neovim.

## Overview

| Component | Tool |
| --- | --- |
| **OS** | Arch Linux |
| **Window Manager** | Hyprland (Wayland) |
| **Editor** | Neovim |
| **Terminal** | Kitty |
| **Shell** | Zsh (Starship, zoxide, mise) |
| **PDF Viewer** | Zathura |
| **Bar** | Waybar |
| **Launcher** | Wofi |

## Key Features

- **Floating Gemini Scratchpad**: Toggles a floating Gemini window on `$mainMod + Space`.
- **Neovim & Zathura SyncTeX**: Auto-scroll SyncTeX forward search without obtrusive highlights.
- **Stow Integration**: Modular symlink management with `install.sh`.

## Installation

```bash
git clone https://github.com/Sh1ragami/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

### Post-Installation

Set your local Git configuration:

```bash
git config --file ~/.gitconfig.local user.name "Your Name"
git config --file ~/.gitconfig.local user.email "your-email@example.com"
```

## Keybindings

| Shortcut | Function |
| --- | --- |
| `$mainMod + Space` | Toggle floating Gemini |
| `$mainMod + G` | Open tiled Gemini |
| `$mainMod + T` | Open terminal |
| `$mainMod + E` | Open file manager |
| `$mainMod + V` | Toggle floating window |
| `$mainMod + Q` | Close window |

## Maintenance

Update package lists:

```bash
pacman -Qqen > ~/dotfiles/pkglist.txt
pacman -Qqem > ~/dotfiles/aurlist.txt
```
