# =============================================================================
# FILE NAVIGATION
# =============================================================================
alias vbp="vim ~/.zshrc"
alias sbp="source ~/.zprofile && source ~/.zshrc && clear"
alias vimrc="vim ~/.vimrc"
alias sshconf="vim ~/.ssh/cloudflare/config"

alias ls="command ls -FGh"
alias la="ls -FGha"
alias sl="ls"

goto() { mkdir -p "$1" && cd "$1"; }
..() { cd ../"$1"; }

# =============================================================================
# TMUX
# =============================================================================
alias t="tmux"
alias tl="tmux ls"
alias tmuxconf="vim ~/.tmux.conf"

ta() {
  if [ $# -eq 0 ]; then
    if tmux ls 2>/dev/null; then
      tmux a -t $(tmux ls | head -n 1 | cut -d ':' -f 1)
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
alias clc="fc -ln -1 | awk '{\$1=\$1}1' | pbcopy"
alias c="tr -d '\n' | pbcopy"
alias path='echo -e ${PATH//:/\\n}'
alias diff="/opt/homebrew/opt/diffutils/bin/diff"
alias sed="gsed"
alias tidy="go mod tidy && go mod vendor"
alias mcsdev="co -b mcs-dev"
alias touchtail="touch $1 && tail -f $1"
alias go23="/opt/homebrew/Cellar/go@1.23/1.23.8/bin/go"

cookie() { export RM_COOKIE="$1"; }
bearer() { export RM_BEARER="$1"; }

jwt-decode() {
  sed 's/\./\n/g' <<< $(cut -d. -f1,2 <<< $1) | base64 --decode | jq
}

# =============================================================================
# TEMPORAL
# =============================================================================
alias tcsync="source ~/.tctl-tls-setup.sh"
alias tdbg="~/Documents/code/temporal/temporal/tdbg --tls-cert-path=/Users/kdeems/.config/temporalio/cert.crt --tls-key-path=/Users/kdeems/.config/temporalio/cert.key --tls-ca-path=/Users/kdeems/.config/temporalio/ca.crt "

# =============================================================================
# WORKERS / NPM (lazy loaded)
# =============================================================================
# NPM_TOKEN is fetched lazily when needed by npm commands
_fetch_npm_token() {
  if [[ -z "$NPM_TOKEN" ]]; then
    export NPM_TOKEN=$(cloudflared access login https://registry.cloudflare-ui.com 2>/dev/null | grep ey)
  fi
}

# Hook into npm to fetch token when needed
_npm_with_token() {
  _fetch_npm_token
  command npm "$@"
}

# Refresh and cache NPM_TOKEN for non-interactive shells (e.g., OpenCode)
refresh_npm_token() {
  export NPM_TOKEN=$(cloudflared access login https://registry.cloudflare-ui.com 2>/dev/null | grep ey)
  echo "$NPM_TOKEN" > ~/.npm_token_cache
  echo "NPM_TOKEN refreshed and cached"
}

# Prettier alias (use homebrew version)
alias prettier='/opt/homebrew/bin/prettier'
