# Dotfiles

Shell configuration for sesh + zoxide + tmux + git worktree integration.

## Quick Setup

```bash
git clone git@github.com:kevindweb/dotfiles.git ~/Documents/code/gitlab/dotfiles && cd ~/Documents/code/gitlab/dotfiles && ./setup.sh
```

## Manual Setup

1. Clone the repo:

   ```bash
   git clone git@github.com:kevindweb/dotfiles.git ~/Documents/code/gitlab/dotfiles
   ```

2. Run the setup script:

   ```bash
   cd ~/Documents/code/gitlab/dotfiles
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
# Source .zprofile only if not already loaded (non-login shells)
[[ -z "$HOMEBREW_PREFIX" ]] && source ~/.zprofile

# =============================================================================
# DOTFILES - Source all shell modules
# =============================================================================
DOTFILES_DIR="$HOME/Documents/code/gitlab/dotfiles"

if [[ -d "$DOTFILES_DIR/zsh" ]]; then
  for file in "$DOTFILES_DIR"/zsh/*.zsh(N); do
    source "$file"
  done
else
  echo "Warning: Dotfiles not found at $DOTFILES_DIR"
fi

# =============================================================================
# LOCAL OVERRIDES (machine-specific, not in git)
# =============================================================================
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
```

## What's Included

- **zsh/**: Modular shell configs (git, kube, projects, utils, etc.)
- **bin/**: Helper scripts (sesh-picker)
- **home/**: Config files symlinked to home directory (.tmux.conf, sesh config)

## Key Bindings (after setup)

| Action                 | Binding              |
| ---------------------- | -------------------- |
| Open session picker    | `Ctrl-a K` (in tmux) |
| Switch to last session | `Ctrl-a L`           |
| Jump to directory      | `z <partial-name>`   |
