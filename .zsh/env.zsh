# shellcheck shell=bash
# =============================================================================
# SHELL BOOTSTRAP
# =============================================================================
# Source .zprofile only if not already loaded (non-login shells)
# shellcheck source=/dev/null
[[ -z "$HOMEBREW_PREFIX" ]] && source ~/.zprofile

# =============================================================================
# ENVIRONMENT VARIABLES
# =============================================================================
export BUILDKIT_PROGRESS=plain
export NODE_OPTIONS="--use-openssl-ca"
export PYTHON=python3
export CLICOLOR=1
export LSCOLORS="BxBxhxDxfxhxhxhxhxcxcx"
export DOTFILES=~/Documents/code/github/dotfiles
export HOMEBREW_AUTO_UPDATE_SECS=172800
export HOMEBREW_NO_ENV_HINTS=1

alias setup='${DOTFILES}/setup.sh'

# GPG
GPG_TTY=$(tty)
export GPG_TTY

# =============================================================================
# PROMPT (starship)
# =============================================================================
eval "$(starship init zsh)"
