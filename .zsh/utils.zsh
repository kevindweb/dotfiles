# shellcheck shell=bash
# =============================================================================
# HOMEBREW (must be first for other tools to work)
# =============================================================================
eval "$(/opt/homebrew/bin/brew shellenv)"
# shellcheck source=/dev/null
[[ -z "$HOMEBREW_PREFIX" ]] && source ~/.zprofile
# shellcheck source=/dev/null
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# =============================================================================
# FILE NAVIGATION
# =============================================================================
alias vbp="vim ~/.zshrc"
alias sbp="source ~/.zprofile && source ~/.zshrc && clear"
alias vimrc="vim ~/.vimrc"

# shellcheck disable=SC2032
alias ls="command ls -FGh"
alias la="ls -FGha"
alias sl="ls"

goto() { mkdir -p "$1" && cd "$1" || return; }
..() { cd ../"$1" || return; }

# =============================================================================
# TMUX
# =============================================================================
alias t="tmux"
alias tl="tmux ls"
alias tmuxconf="vim ~/.tmux.conf"

ta() {
  if [ $# -eq 0 ]; then
    # shellcheck disable=SC2033
    if command tmux ls 2>/dev/null; then
      # shellcheck disable=SC2033
      tmux a -t "$(command tmux ls | head -n 1 | cut -d ':' -f 1)"
    else
      tmux
    fi
  else
    tmux a -t "$1"
  fi
}

# =============================================================================
# UTILITIES
# =============================================================================
alias sudo="sudo "
clc() { fc -ln -1 | awk '{$1=$1}1' | pbcopy; }
alias c="tr -d '\n' | pbcopy"
alias path='echo -e ${PATH//:/\\n}'
alias diff="/opt/homebrew/opt/diffutils/bin/diff"
alias sed="gsed"
touchtail() { touch "$1" && tail -f "$1"; }

jwt-decode() {
  cut -d. -f1,2 <<< "$1" | tr '.' '\n' | base64 --decode | jq
}
