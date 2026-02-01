# shellcheck shell=bash
# =============================================================================
# ENVIRONMENT VARIABLES
# =============================================================================
export BUILDKIT_PROGRESS=plain
export NODE_OPTIONS="--use-openssl-ca"
export PYTHON=python3
export CLICOLOR=1
export LSCOLORS="BxBxhxDxfxhxhxhxhxcxcx"

# GPG
GPG_TTY=$(tty)
export GPG_TTY
