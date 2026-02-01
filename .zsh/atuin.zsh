# shellcheck shell=bash
# =============================================================================
# ATUIN - Shell History Sync & Search
# =============================================================================
# Replaces Ctrl+R with enhanced history search
# Syncs history across machines (optional)

if command -v atuin &>/dev/null; then
  eval "$(atuin init zsh --disable-up-arrow)"
fi
