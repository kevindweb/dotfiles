#!/usr/bin/env bash
# Symlink dotfiles to home directory

set -euo pipefail
DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

log() { echo "=> $*"; }

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

# Link config directories
mkdir -p "$HOME/.config/sesh"
link "$DOTFILES_DIR/home/.config/sesh/sesh.toml" "$HOME/.config/sesh/sesh.toml"

# Link bin scripts
mkdir -p "$HOME/bin"
for script in "$DOTFILES_DIR/bin/"*; do
	[[ -f "$script" ]] && link "$script" "$HOME/bin/$(basename "$script")"
done

log "Done! Restart your shell or run: source ~/.zshrc"
