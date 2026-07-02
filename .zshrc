# ~/.zshrc — managed by dotfiles repo

export ZSH="$HOME/.oh-my-zsh"

# Theme (no powerline font dependency, shows git status)
ZSH_THEME="af-magic"

# Plugins
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source "$ZSH/oh-my-zsh.sh"

# ---- Personal aliases/shortcuts ----
[ -f "$HOME/.aliases" ] && source "$HOME/.aliases"

# ---- Path additions ----
export PATH="$HOME/.local/bin:$PATH"

# ---- History ----
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
