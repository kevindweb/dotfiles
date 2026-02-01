# Project Agent Instructions

## Working Directory Constraints

**CRITICAL**: All file operations must stay within the project root:
`/Users/kdeems/Documents/code/worktrees/dotfiles/main`

### For explore/librarian agents:

- NEVER search from root (`/`) or home directory (`~`)
- ALWAYS constrain searches to the project root or specific subdirectories
- The project structure is:
  ```
  ./zsh/           - Shell configuration files (*.zsh)
  ./home/          - Config files symlinked to ~ (.tmux.conf, .vimrc, etc)
  ./bin/           - Helper scripts
  ./setup.sh       - Installation script
  ```

### Key Files:

- `zsh/git.zsh` - Git aliases and functions
- `zsh/opencode.zsh` - oc-split and opencode launcher
- `zsh/utils.zsh` - General utilities
- `home/.config/Code/User/settings.json` - VS Code settings
- `home/.tmux.conf` - Tmux configuration

### DO NOT:

- Grep in `/`, `/usr`, `/etc`, or any system directories
- Search outside the project unless explicitly asked
- Assume files are in standard system locations
