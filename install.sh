#!/usr/bin/env bash
# install.sh — bootstrap dotfiles on a new machine or container
# Usage: ./install.sh

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Detecting package manager..."

# Use sudo if not root and sudo is available non-interactively
SUDO=""
if [ "$(id -u)" -ne 0 ]; then
  if command -v sudo >/dev/null 2>&1 && sudo -n true 2>/dev/null; then
    SUDO="sudo"
  fi
fi

install_pkgs() {
  if command -v apt >/dev/null 2>&1; then
    $SUDO apt update && $SUDO apt install -y "$@"
  elif command -v pacman >/dev/null 2>&1; then
    $SUDO pacman -Sy --noconfirm "$@"
  else
    echo "No supported package manager found (apt or pacman). Install zsh/git/curl manually and re-run." >&2
    exit 1
  fi
}

echo "==> Installing zsh, git, curl..."
if ! install_pkgs zsh git curl; then
  echo "" >&2
  echo "ERROR: package install failed. This usually means you're not root and passwordless" >&2
  echo "sudo isn't set up in this container. Either:" >&2
  echo "  - run this script as root (many containers default to root), or" >&2
  echo "  - add your user to sudoers with NOPASSWD, or" >&2
  echo "  - pre-bake zsh/git/curl into your container image instead." >&2
  exit 1
fi

echo "==> Installing oh-my-zsh (unattended)..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "    oh-my-zsh already installed, skipping."
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

echo "==> Installing zsh-autosuggestions and zsh-syntax-highlighting plugins..."
[ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ] || \
  git clone --quiet https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
[ -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ] || \
  git clone --quiet https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

echo "==> Symlinking dotfiles into \$HOME..."
for file in .zshrc .aliases .gitconfig; do
  target="$HOME/$file"
  source="$DOTFILES_DIR/$file"
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    echo "    Backing up existing $target -> $target.bak"
    mv "$target" "$target.bak"
  fi
  ln -sfn "$source" "$target"
  echo "    Linked $target -> $source"
done

echo "==> Setting zsh as default shell..."
if [ "$SHELL" != "$(command -v zsh)" ]; then
  $SUDO chsh -s "$(command -v zsh)" "$(whoami)" || echo "    Could not chsh automatically. Run manually: chsh -s \$(command -v zsh)"
fi

echo ""
echo "Done. Start a new shell or run: exec zsh"
echo "Remember to edit ~/.gitconfig with your real name/email (or it's symlinked, so edit $DOTFILES_DIR/.gitconfig)."