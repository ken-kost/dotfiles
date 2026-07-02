# dotfiles

Personal shell setup: oh-my-zsh, git-aware prompt, autosuggestions, syntax highlighting, and a few shortcuts.

## What's inside

- `.zshrc` — oh-my-zsh config (theme: `af-magic`, plugins: git, autosuggestions, syntax-highlighting)
- `.aliases` — navigation and git shortcuts, sourced from `.zshrc`
- `.gitconfig` — base git config with aliases (edit name/email before use)
- `install.sh` — bootstrap script, works on Ubuntu/Debian (`apt`) and Arch/Omarchy (`pacman`)

## Usage

### Option A — clone from your own git remote (recommended)

Push this folder to a private repo (e.g. `github.com/you/dotfiles`), then on any new machine or container:

```bash
git clone https://github.com/you/dotfiles.git ~/dotfiles
cd ~/dotfiles
chmod +x install.sh
./install.sh
```

### Option B — one-liner without cloning manually

Once pushed to GitHub, you can bootstrap a fresh container in one line:

```bash
git clone https://github.com/you/dotfiles.git ~/dotfiles && ~/dotfiles/install.sh
```

### Option C — copy files in manually

If you don't want a git remote, just copy this folder into the container (e.g. via `docker cp`, a Coder startup script, or mounting a volume) and run `install.sh` from inside it.

## What install.sh does

1. Detects `apt` or `pacman` and installs `zsh`, `git`, `curl`
2. Installs oh-my-zsh non-interactively (doesn't overwrite your `.zshrc` before symlinking)
3. Clones `zsh-autosuggestions` and `zsh-syntax-highlighting` plugins
4. Symlinks `.zshrc`, `.aliases`, `.gitconfig` from this repo into `$HOME` (backs up any existing files as `.bak`)
5. Sets zsh as the default shell

Because the configs are **symlinked**, editing them later just means editing the files in this repo — changes take effect immediately and you can `git commit` them.

## Baking into a container image

For a Coder/devcontainer image so this survives rebuilds automatically, add to your `Dockerfile`:

```dockerfile
RUN git clone https://github.com/you/dotfiles.git /opt/dotfiles \
  && bash /opt/dotfiles/install.sh
```

## After first install

Edit your identity (don't hardcode it in a public repo's `.gitconfig`):

```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```
