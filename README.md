# Dotfiles

Shell configuration for sesh + zoxide + tmux + git worktree integration.

## Quick Setup

```bash
mkdir -p ~/Documents/code/github && git clone git@github.com:kevindweb/dotfiles.git ~/Documents/code/github/dotfiles && cd ~/Documents/code/github/dotfiles && ./setup.sh
```

## Manual Setup

1. Clone the repo:

   ```bash
   git clone git@github.com:kevindweb/dotfiles.git ~/Documents/code/github/dotfiles
   ```

2. Run the setup script:

   ```bash
   cd ~/Documents/code/github/dotfiles
   ./setup.sh
   ```

3. Update your `~/.zshrc` to source the dotfiles (see below).

4. Reload your shell:
   ```bash
   source ~/.zshrc
   ```

## ~/.zshrc Configuration

Add this to your `~/.zshrc` to source the dotfiles:

```bash
if [[ -d "$HOME/zsh" ]]; then
  for file in "$HOME"/zsh/**/*.zsh(N); do
    source "$file"
  done
else
  echo "Warning: ~/zsh not found. Run dotfiles setup.sh"
fi
```

## What's Included

- **zsh/**: Modular shell configs (git, kube, projects, utils, etc.) → symlinked to `~/zsh`
- **zsh/cloudflare/**: Work-specific configs (gitignored, not committed)
- **bin/**: Helper scripts (sesh-picker) → symlinked to `~/bin/`
- **home/**: Config files symlinked to home directory (.tmux.conf, sesh config)
