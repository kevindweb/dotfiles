#!/usr/bin/env bash
# Dotfiles setup: Install dependencies and symlink configurations

set -euo pipefail
DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

log() { echo "=> $*"; }

# =============================================================================
# HOMEBREW
# =============================================================================

# Install Homebrew if not present
install_homebrew() {
	if command -v brew &>/dev/null; then
		log "Homebrew already installed, updating..."
		brew update || true
		return
	fi
	log "Installing Homebrew..."
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

	# Add brew to PATH for this session (macOS arm64)
	if [[ -f /opt/homebrew/bin/brew ]]; then
		eval "$(/opt/homebrew/bin/brew shellenv)"
	fi
}

# Install packages from Brewfile
install_packages() {
	if [[ ! -f "$DOTFILES_DIR/Brewfile" ]]; then
		log "No Brewfile found, skipping package installation"
		return
	fi
	log "Installing packages from Brewfile..."
	brew bundle --file="$DOTFILES_DIR/Brewfile" || {
		log "Warning: brew bundle had errors (non-fatal, continuing)"
	}
}

install_homebrew
install_packages

# =============================================================================
# SYMLINKS
# =============================================================================

# Symlink a file, backing up existing
link() {
	local src="$1" dest="$2"
	if [[ -e "$dest" && ! -L "$dest" ]]; then
		log "Backing up $dest to $dest.bak"
		mv "$dest" "$dest.bak"
	fi
	if [[ -L "$dest" ]]; then
		rm "$dest"
	fi
	log "Linking $dest -> $src"
	ln -s "$src" "$dest"
}

# Link home/ files
link "$DOTFILES_DIR/home/.tmux.conf" "$HOME/.tmux.conf"
link "$DOTFILES_DIR/home/.vimrc" "$HOME/.vimrc"

# Link .zsh directory (contains all shell modules)
link "$DOTFILES_DIR/.zsh" "$HOME/.zsh"

# Link config directories
mkdir -p "$HOME/.config/sesh"
link "$DOTFILES_DIR/home/.config/sesh/sesh.toml" "$HOME/.config/sesh/sesh.toml"

# =============================================================================
# VS CODE
# =============================================================================

# Copy VSCode settings (create if not exists, don't overwrite)
mkdir -p "$HOME/Library/Application Support/Code/User"
vscode_settings="$HOME/Library/Application Support/Code/User/settings.json"
vscode_keybindings="$HOME/Library/Application Support/Code/User/keybindings.json"
if [[ ! -e "$vscode_settings" ]]; then
	log "Creating $vscode_settings"
	cp "$DOTFILES_DIR/home/.config/Code/User/settings.json" "$vscode_settings"
else
	log "VSCode settings.json already exists, skipping"
fi
if [[ ! -e "$vscode_keybindings" ]]; then
	log "Creating $vscode_keybindings"
	cp "$DOTFILES_DIR/home/.config/Code/User/keybindings.json" "$vscode_keybindings"
else
	log "VSCode keybindings.json already exists, skipping"
fi

# =============================================================================
# SCRIPTS
# =============================================================================

# Link bin scripts
mkdir -p "$HOME/bin"
for script in "$DOTFILES_DIR/bin/"*; do
	[[ -f "$script" ]] && link "$script" "$HOME/bin/$(basename "$script")"
done

# Link git hooks for this repo
link "$DOTFILES_DIR/hooks/pre-commit" "$DOTFILES_DIR/.git/hooks/pre-commit"

log "Done! Restart your shell or run: source ~/.zshrc"
