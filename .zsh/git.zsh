# shellcheck shell=bash
# =============================================================================
# GIT ALIASES
# =============================================================================

alias gs="git status"
alias ga="git add"
alias gaa="git add -A"
alias gd="git diff"
# gb is now a function - see below
alias gp="git pull"
alias gpf="git push -f"
alias gf="git forget"
alias fa="git fetch --all"
alias newbranch="git checkout -b"
alias branches="git branch -v"
alias staging="git checkout staging"
alias stage="git checkout staging"
alias stash="git stash"
alias rebase="git rebase"
alias rb="rebase"
alias gl="git log"
alias gprune="git remote prune origin"

# =============================================================================
# GIT FUNCTIONS
# =============================================================================

# Get main branch name (main or master)
git_main_branch() {
  command git rev-parse --git-dir &>/dev/null || return 1
  if git show-ref -q --verify refs/heads/main; then
    echo main
  elif git show-ref -q --verify refs/heads/master; then
    echo master
  else
    echo "Neither 'main' nor 'master' branch found." >&2
    return 1
  fi
}

gb() {
  echo "=== Branches ==="
  git branch -v
  echo ""
  echo "=== Worktrees ==="
  git worktree list
}

rbm() {
  local branch
  branch=$(git_main_branch) || return 1
  git rebase "$branch"
}

# Open VS Code at the main repo root (not worktree) showing the main/master branch
main() {
  local git_common_dir repo_root
  git_common_dir=$(git rev-parse --git-common-dir 2>/dev/null) || {
    echo "Error: Not in a git repository"
    return 1
  }
  # Get the repo root (parent of .git dir)
  # In worktree: git_common_dir is full path like /path/to/repo/.git
  # In main repo: git_common_dir is just ".git"
  if [[ "$git_common_dir" == ".git" ]]; then
    repo_root=$(git rev-parse --show-toplevel)
  else
    repo_root=$(dirname "$git_common_dir")
  fi
  code -r "$repo_root"
}

master() {
  main
}

changes() {
  local branch
  branch=$(git_main_branch) || return 1
  git diff --stat "$branch".. -- . ':!vendor'
}

gamend() {
  now=$(date -R)
  git commit --amend --date="$now"
}

gaamend() {
  now=$(date -R)
  git add -A && git commit --amend --date="$now"
}

gamendn() {
  now=$(date -R)
  git commit --amend --no-edit --date="$now"
}

gaamendn() {
  now=$(date -R)
  git add -A && git commit --amend --no-edit --date="$now"
}

gaumend() {
  now=$(date -R)
  git add -u . && git commit --amend --date="$now"
}

gaumendn() {
  now=$(date -R)
  git add -u . && git commit --amend --no-edit --date="$now"
}

squash() {
  local branch
  branch=$(git_main_branch) || return 1
  printf "Squashing with %s as head\n" "$branch"
  git reset "$(git merge-base "$branch" "$(git branch --show-current)")"
  echo "Remember to git commit -am 'Commit message'"
}

pb() { git push -f -u origin "$(git branch --show-current)"; }

cob() {
  git fetch --all
  git checkout -b "$1" "origin/$1" || git checkout "$1"
}

gbd() {
  local input="$1"
  if [[ -z "$input" ]]; then
    echo "Usage: gbd <branch-name> (with or without kdeems/ prefix)"
    return 1
  fi

  # Normalize: strip kdeems/ prefix if provided
  local branch="${input#kdeems/}"

  # Must be in a git repo
  local repo_root repo_name
  repo_root=$(git rev-parse --show-toplevel 2>/dev/null) || {
    echo "Error: Not in a git repository"
    return 1
  }
  repo_name=$(basename "$repo_root")

  local worktree_path="$HOME/Documents/code/worktrees/$repo_name/$branch"

  # Kill tmux session if it exists (try both forms)
  if tmux has-session -t "$branch" 2>/dev/null; then
    tmux kill-session -t "$branch"
    echo "Killed tmux session: $branch"
  fi
  if tmux has-session -t "kdeems/$branch" 2>/dev/null; then
    tmux kill-session -t "kdeems/$branch"
    echo "Killed tmux session: kdeems/$branch"
  fi

  # Remove worktree if it exists
  if [[ -d "$worktree_path" ]]; then
    git worktree remove "$worktree_path" --force 2>/dev/null || {
      # If worktree remove fails, try manual cleanup
      rm -rf "$worktree_path"
      git worktree prune
    }
    echo "Removed worktree: $worktree_path"
  fi

  # Delete local branches (both forms)
  git branch -D "kdeems/$branch" 2>/dev/null && echo "Deleted branch: kdeems/$branch"
  git branch -D "$branch" 2>/dev/null && echo "Deleted branch: $branch"

  # Prune remote refs
  git remote prune origin 2>/dev/null
}

gpd() { git push -d origin "$1"; }

co() {
  local input="$1"
  if [[ -z "$input" ]]; then
    echo "Usage: co <branch-name>"
    return 1
  fi

  # Normalize: strip kdeems/ prefix if provided
  local branch="${input#kdeems/}"

  # Must be in a git repo
  local repo_root repo_name
  repo_root=$(git rev-parse --show-toplevel 2>/dev/null) || {
    echo "Error: Not in a git repository"
    return 1
  }
  repo_name=$(basename "$repo_root")

  local worktree_base="$HOME/Documents/code/worktrees/$repo_name"
  local worktree_path="$worktree_base/$branch"
  local full_branch="kdeems/$branch"

  # Create worktree if it doesn't exist
  if [[ ! -d "$worktree_path" ]]; then
    mkdir -p "$worktree_base"

    # Determine base branch (main or master)
    local base_branch
    base_branch=$(git_main_branch) || return 1

    # Create the worktree with new branch
    git worktree add -b "$full_branch" "$worktree_path" "$base_branch" || {
      echo "Error: Failed to create worktree"
      return 1
    }
    echo "Created worktree: $worktree_path (branch: $full_branch)"
  else
    echo "Worktree exists: $worktree_path"
  fi

  # Open VS Code (tmuxoc profile will handle tmux via oc-split)
  code -r "$worktree_path"
}

commit() {
  ticket=$(git rev-parse --abbrev-ref HEAD | cut -d / -f 2 | cut -d - -f1,2)
  message="$ticket $*"
  git commit -m "$message"
}
