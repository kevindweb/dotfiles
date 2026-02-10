# shellcheck shell=bash
# =============================================================================
# OPENCODE LAUNCHER
# =============================================================================

oc-split() {
  local name
  # Sanitize: dots and colons are tmux target delimiters (session.window.pane / session:window)
  name=$(basename "$(pwd)" | tr './:' '_')

  # Reuse existing session if it exists
  if tmux has-session -t "=$name" 2>/dev/null; then
    tmux attach -t "=$name"
    return
  fi

  # Create new session with opencode split
  tmux new-session -d -s "$name" -c "$(pwd)"
  tmux split-window -h -t "$name" "opencode"
  tmux select-pane -t "$name:.{left}"
  tmux attach -t "$name"
}
