# =============================================================================
# GIT ALIASES
# =============================================================================
alias gs="git status"
alias ga="git add"
alias gaa="git add -A"
alias gd="git diff"
alias gb="git branch"
alias gp="git pull"
alias gpf="git push -f"
alias gf="git forget"
alias fa="git fetch --all"
alias newbranch="git checkout -b"
# co is now a function (see GIT WORKTREES section)
alias branches="git branch -v"

alias staging="git checkout staging"
alias stage="git checkout staging"
alias stash="git stash"
alias rebase="git rebase"
alias backstage="cf-backstage-cli"
alias rb="rebase"
alias gl="git log"
alias gprune="git remote prune origin"

# =============================================================================
# GIT FUNCTIONS
# =============================================================================
rbm() {
  if git rev-parse --verify master >/dev/null 2>&1; then
    branch="master"
  elif git rev-parse --verify main >/dev/null 2>&1; then
    branch="main"
  else
    echo "Neither 'master' nor 'main' branch found."
    return 1
  fi
  git rebase "$branch"
}

changes() {
  if git rev-parse --verify master >/dev/null 2>&1; then
    branch="master"
  elif git rev-parse --verify main >/dev/null 2>&1; then
    branch="main"
  else
    echo "Neither 'master' nor 'main' branch found."
    return 1
  fi
  git diff --stat "$branch".. -- . ':!vendor'
}

local_git() {
  git config --global commit.gpgsign true
  git config --global user.email "kevin8deems@gmail.com"
  git config --global user.signingkey "91E05E84E00C8CCE"
}

global_git() {
  git config --global commit.gpgsign false
  git config --global user.email "kdeems@cloudflare.com"
  git config --global user.signingkey ""
}

gamend() {
  now=$(date -R)
  git commit --amend --date=$now
}
gaamend() {
  now=$(date -R)
  git add -A && git commit --amend --date=$now
}
gamendn() {
  now=$(date -R)
  git commit --amend --no-edit --date=$now
}
gaamendn() {
  now=$(date -R)
  git add -A && git commit --amend --no-edit --date=$now
}
gaumend() {
  now=$(date -R)
  git add -u . && git commit --amend --date=$now
}
gaumendn() {
  now=$(date -R)
  git add -u . && git commit --amend --no-edit --date=$now
}

delete_origin_branches() {
  local regex_pattern="$USER/MCS-.*_revert$"
  local time_threshold="5"
  local branches=($(git ls-remote --heads origin | awk -F'/' -v pattern="$regex_pattern" '$0 ~ pattern {print $NF}'))

  if [ ${#branches[@]} -eq 0 ]; then
    echo "No branches found matching the given pattern."
    return 0
  fi

  echo "Deleting the following branches from origin:"
  local count=0

  for branch in "${branches[@]}"; do
    branch="$USER/$branch"
    local last_updated=$(git show --no-patch --no-notes --pretty='%cd' --date=iso "origin/$branch" | tail -n 1)
    local branch_timestamp=$(date -j -f "%Y-%m-%d %H:%M:%S %z" "$last_updated" "+%s")
    local current_timestamp=$(date +%s)
    local time_diff=$(( (current_timestamp - branch_timestamp) / (60*60*24) ))

    if [[ -z "$time_threshold" || $time_diff -gt $time_threshold ]]; then
      echo "- $branch"
      git push origin --delete "$branch"
      ((count++))
    fi
  done

  echo "Total branches: ${#branches[@]}"
  echo "Branch deletion complete. $count branches removed."
}

rel() { git checkout kdeems/REL-$1; }
comcs() { git checkout kdeems/MCS-$1; }
squash() {
  echo "Squashing with master as head\n"
  git reset $(git merge-base master $(git branch --show-current))
  echo "Remember to git commit -am 'Commit message'"
}
pb() { git push -f -u origin $(git branch --show-current); }
cob() {
  git fetch --all
  git checkout -b $1 origin/$1 || git checkout $1
}
# nb is now a function (see GIT WORKTREES section)
gbd() {
  {
    git branch -D kdeems/MCS-$1 || true
    git branch -D kdeems/MCS-${1}_revert || true
    git branch -D $1 || true
    git branch -D ${1}_revert || true
  } &> /dev/null
  gprune
}
gpd() { git push -d origin $1; }
commit() {
  ticket=$(git rev-parse --abbrev-ref HEAD | cut -d / -f 2 | cut -d - -f1,2)
  message="$ticket $@"
  git commit -m "$message"
}

# =============================================================================
# GIT WORKTREES
# =============================================================================
WORKTREES_DIR="$HOME/Documents/code/worktrees"

# nb (new branch) - creates a worktree instead of switching branches
# Usage: nb MCS-1234 [base-branch]
#   nb 1234           → creates worktree from main/master
#   nb 1234 staging   → creates worktree from staging
nb() {
  local ticket="$1"
  local base="${2:-}"
  
  if [[ -z "$ticket" ]]; then
    echo "Usage: nb <ticket> [base-branch]"
    echo "  nb 1234           # creates from main/master"
    echo "  nb 1234 staging   # creates from staging"
    return 1
  fi
  
  # Get project name from current git repo
  local project
  project=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)") || {
    echo "Error: Not in a git repository"
    return 1
  }
  
  # Determine base branch
  if [[ -z "$base" ]]; then
    if git rev-parse --verify main &>/dev/null; then
      base="main"
    elif git rev-parse --verify master &>/dev/null; then
      base="master"
    else
      echo "Error: No main/master branch found. Specify base branch."
      return 1
    fi
  fi
  
  # Ensure we're up to date
  git fetch origin "$base" 2>/dev/null
  
  local branch_name="kdeems/MCS-$ticket"
  local wt_path="$WORKTREES_DIR/$project/MCS-$ticket"
  
  # Create worktrees directory structure
  mkdir -p "$WORKTREES_DIR/$project"
  
  # Create the worktree with new branch
  echo "Creating worktree: $wt_path"
  echo "Branch: $branch_name (from $base)"
  
  if git worktree add -b "$branch_name" "$wt_path" "origin/$base"; then
    echo ""
    echo "✓ Worktree created!"
    
    # Track with zoxide so sesh can find it
    command -v zoxide &>/dev/null && zoxide add "$wt_path"
    
    echo "  cd $wt_path"
    cd "$wt_path"
    
    if [[ -n "${TMUX:-}" ]]; then
      echo "Tip: Use 'sesh connect $wt_path' for dedicated session"
    fi
  else
    echo "Error: Failed to create worktree"
    return 1
  fi
}

# wt - switch to existing worktree or list them
# Usage: wt [identifier]
#   wt                        → list worktrees for current project
#   wt 1234                   → cd to MCS-1234 worktree
#   wt personal-agents        → cd to personal-agents worktree (by dir name)
#   wt kdeems/personal-agents → cd to worktree on that branch
wt() {
  local identifier="$1"
  
  local project
  project=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)") || {
    echo "Error: Not in a git repository"
    return 1
  }
  
  if [[ -z "$identifier" ]]; then
    # List worktrees
    echo "Worktrees for $project:"
    git worktree list
    return 0
  fi
  
  # Try REL- prefix first
  local wt_path="$WORKTREES_DIR/$project/REL-$identifier"
  if [[ -d "$wt_path" ]]; then
    cd "$wt_path"
    return 0
  fi
  
  # Try MCS- prefix first
  wt_path="$WORKTREES_DIR/$project/MCS-$identifier"
  if [[ -d "$wt_path" ]]; then
    cd "$wt_path"
    return 0
  fi
  
  # Try direct directory name
  wt_path="$WORKTREES_DIR/$project/$identifier"
  if [[ -d "$wt_path" ]]; then
    cd "$wt_path"
    return 0
  fi
  
  # Try matching by branch name
  local wt_line
  wt_line=$(git worktree list | grep -E "\[$identifier\]$")
  if [[ -n "$wt_line" ]]; then
    wt_path=$(echo "$wt_line" | awk '{print $1}')
    cd "$wt_path"
    return 0
  fi
  
  echo "Worktree not found: $identifier"
  echo "Available:"
  ls "$WORKTREES_DIR/$project" 2>/dev/null || echo "  (none)"
  echo ""
  echo "Branches:"
  git worktree list | tail -n +2 | awk '{print "  " $3}'
  return 1
}

# wtc - get into worktree with VS code
wtc() {
  local branch="$1"
  wt $1 && code .
}

# wtd - delete worktree AND its branch (interactive with fzf, or by name)
# Usage: 
#   wtd             → fzf selection from worktree list
#   wtd 1234        → delete MCS-1234 worktree + branch
#   wtd dirname     → delete by worktree directory name
wtd() {
  local identifier="$1"
  local project wt_path branch main_wt force_flag=""
  
  # Get current project
  project=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)") || {
    echo "Error: Not in a git repository"
    return 1
  }
  
  main_wt=$(git worktree list | head -1 | awk '{print $1}')
  
  if [[ -z "$identifier" ]]; then
    # Interactive fzf selection
    local selected
    selected=$(git worktree list | tail -n +2 | fzf \
      --prompt="Delete worktree: " \
      --height 40% --reverse \
      --preview 'git -C {1} log --oneline -5 2>/dev/null || echo "No commits"')
    [[ -z "$selected" ]] && return 0
    
    wt_path=$(echo "$selected" | awk '{print $1}')
    branch=$(echo "$selected" | sed -E 's/.*\[([^]]+)\].*/\1/')
  else
    # Find worktree by identifier (ticket or dirname)
    wt_path="$WORKTREES_DIR/$project/MCS-$identifier"
    [[ ! -d "$wt_path" ]] && wt_path="$WORKTREES_DIR/$project/$identifier"
    
    if [[ ! -d "$wt_path" ]]; then
      echo "Worktree not found: $identifier"
      echo "Available:"
      ls "$WORKTREES_DIR/$project" 2>/dev/null || echo "  (none)"
      return 1
    fi
    
    # Get branch name from worktree
    branch=$(git worktree list | grep "^$wt_path " | sed -E 's/.*\[([^]]+)\].*/\1/')
  fi
  
  # Move out if we're in the worktree being deleted
  if [[ "$PWD" == "$wt_path"* ]]; then
    echo "Currently in worktree, moving to main..."
    cd "$main_wt"
  fi
  
  # Check for uncommitted changes
  if ! git -C "$wt_path" diff --quiet 2>/dev/null || \
     ! git -C "$wt_path" diff --cached --quiet 2>/dev/null; then
    echo "⚠️  Worktree has uncommitted changes:"
    git -C "$wt_path" status --short
    echo ""
    read -rp "Force delete? (y/N): " confirm
    [[ ! "$confirm" =~ ^[Yy]$ ]] && return 1
    force_flag="--force"
  fi
  
  # Remove from zoxide before deleting
  command -v zoxide &>/dev/null && zoxide remove "$wt_path" 2>/dev/null || true
  
  # Remove worktree
  echo "Removing worktree: $wt_path"
  if git worktree remove "$wt_path" $force_flag; then
    echo "✓ Worktree removed"
    
    # Delete branch if it exists
    if [[ -n "$branch" && "$branch" != "(detached HEAD)" ]]; then
      echo "Deleting branch: $branch"
      if git branch -d "$branch" 2>/dev/null; then
        echo "✓ Branch deleted"
      else
        # Try force delete for unmerged branches
        git branch -D "$branch" 2>/dev/null && echo "✓ Branch force-deleted (was unmerged)"
      fi
      
      # Also try remote cleanup
      git push origin --delete "$branch" 2>/dev/null && echo "✓ Remote branch deleted"
    fi
    
    git worktree prune
  else
    echo "✗ Failed to remove worktree"
    return 1
  fi
}

# main/master - go back to main repo (first worktree = original repo)
# If in a worktree: cd to main repo
# If in main repo on a different branch: checkout main/master
main() {
  local main_wt
  main_wt=$(git worktree list | head -1 | awk '{print $1}')
  
  # Check if we're in a worktree (not the main repo)
  if [[ "$(git rev-parse --show-toplevel)" != "$main_wt" ]]; then
    cd "$main_wt"
  else
    # We're in the main repo - checkout main/master branch
    if git rev-parse --verify main &>/dev/null; then
      git checkout main
    elif git rev-parse --verify master &>/dev/null; then
      git checkout master
    else
      echo "No main/master branch found"
      return 1
    fi
  fi
}
master() { main; }

# wtls - list all worktrees across all projects
wtls() {
  echo "=== All Worktrees ==="
  if [[ -d "$WORKTREES_DIR" ]]; then
    for project_dir in "$WORKTREES_DIR"/*/; do
      local project=$(basename "$project_dir")
      echo ""
      echo "[$project]"
      if ls -d "$project_dir"*/ &>/dev/null; then
        for wt in "$project_dir"*/; do
          [[ -d "$wt" ]] && echo "  • $(basename "$wt")"
        done
      else
        echo "  (no worktrees)"
      fi
    done
  else
    echo "(no worktrees yet)"
  fi
}

# co - checkout, but co -b creates worktree
# co branch     → checkout existing branch (unchanged)
# co -b branch  → create worktree instead
co() {
  if [[ "$1" == "-b" ]]; then
    shift
    # If it looks like a ticket number, use nb
    if [[ "$1" =~ ^[Mm][Cc][Ss]-?[0-9]+$ ]] || [[ "$1" =~ ^[0-9]+$ ]]; then
      local ticket="${1#MCS-}"
      ticket="${ticket#mcs-}"
      nb "$ticket" "$2"
    else
      # For non-ticket branches, create worktree with given name
      local branch_name="$1"
      local base="${2:-}"
      local project=$(basename "$(git rev-parse --show-toplevel)")
      local wt_path="$WORKTREES_DIR/$project/$branch_name"
      
      [[ -z "$base" ]] && base=$(git rev-parse --abbrev-ref HEAD)
      
      mkdir -p "$WORKTREES_DIR/$project"
      git worktree add -b "kdeems/$branch_name" "$wt_path" "$base" && cd "$wt_path"
      code .
    fi
  else
    # Normal checkout
    git checkout "$@"
  fi
}

alias nbdev="git checkout -b mcs-dev"
alias gbdev="gbd mcs-dev"

# Git config (only run once if needed)
git config --global --get push.autoSetupRemote >/dev/null 2>&1 || \
  git config --global --add --bool push.autoSetupRemote true
