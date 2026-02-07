# shellcheck shell=bash
# =============================================================================
# OPENCODE LAUNCHER
# =============================================================================

oc-split() {
  local name
  name=$(basename "$(pwd)")

  # Reuse existing session if it exists
  if tmux has-session -t "$name" 2>/dev/null; then
    tmux attach -t "$name"
    return
  fi

  # Create new session with opencode split
  tmux new-session -d -s "$name" -c "$(pwd)"
  tmux split-window -h -t "$name" "opencode"
  tmux select-pane -t "$name:0.0"
  tmux attach -t "$name"
}
