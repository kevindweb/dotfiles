# Dotfiles

Shell configuration for sesh + zoxide + tmux + git worktree integration.

## Quick Setup

1. Run

```bash
mkdir -p ~/Documents/code/github && git clone git@github.com:kevindweb/dotfiles.git ~/Documents/code/github/dotfiles && cd ~/Documents/code/github/dotfiles && ./setup.sh
```

2. Update your `~/.zshrc` to source the dotfiles (see below).

3. Reload your shell:
   ```bash
   source ~/.zshrc
   ```

## ~/.zshrc Configuration

Add this to your `~/.zshrc` to source the dotfiles:

```bash
if [[ -d "$HOME/.zsh" ]]; then
  for file in "$HOME"/.zsh/**/*.zsh(N); do
    source "$file"
  done
else
  echo "Warning: ~/.zsh not found. Run dotfiles setup.sh"
fi
```

## What's Included

- **.zsh/**: Modular shell configs (git, kube, projects, utils, etc.) → symlinked to `~/.zsh`
- **.zsh/cloudflare/**: Work-specific configs (gitignored, not committed)
- **bin/**: Helper scripts (sesh-picker) → symlinked to `~/bin/`
- **home/**: Config files symlinked to home directory (.tmux.conf, sesh config)

## GitHub SSH Key Setup (New Laptop)

### Script Step

Run this to generate an SSH key and copy it to clipboard:

```bash
ssh-keygen -t ed25519 -C "kevin8deems@gmail.com" -f ~/.ssh/github -N ""
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/github
cat >> ~/.ssh/config << 'EOF'
Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/github
  AddKeysToAgent yes
EOF
cat ~/.ssh/github.pub | pbcopy
echo "Public key copied to clipboard!"
```

### Manual Step

1. Go to https://github.com/settings/ssh/new
2. Title: `...` (or your device name)
3. Key: Paste from clipboard (Cmd+V)
4. Click **Add SSH key**
5. Test: `ssh -T git@github.com`
