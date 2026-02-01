# =============================================================================
# OPENCODE LAUNCHER
# =============================================================================

# opencoda: Full auth refresh - use when starting a new day or tokens are expired
# This ALWAYS does logout + login to refresh ALL OAuth tokens (including GitLab)
# IMPORTANT: When browser opens, click "Authorize" for EACH server (especially GitLab)
opencoda() {
  local RED='\033[0;31m'
  local GREEN='\033[0;32m'
  local YELLOW='\033[1;33m'
  local BLUE='\033[0;34m'
  local NC='\033[0m'

  local REQUIRED_MCPS=("cf-portal")

  log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
  log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
  log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
  log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

  auth_opencode() {
    log_info "Authenticating OpenCode with Cloudflare Access..."
    echo ""
    if command opencode auth login https://opencode.cloudflare.dev; then
      log_success "Successfully authenticated OpenCode"
      return 0
    else
      log_error "Failed to authenticate OpenCode"
      return 1
    fi
  }

  logout_mcp() {
    local mcp_name=$1
    log_info "Logging out MCP: $mcp_name..."
    command opencode mcp logout "$mcp_name" 2>/dev/null || true
  }

  auth_mcp() {
    local mcp_name=$1
    log_info "Authenticating MCP: $mcp_name..."
    echo -e "${YELLOW}>>> IMPORTANT: In the browser, click 'Authorize' for EACH server <<<${NC}"
    echo -e "${YELLOW}>>> Tokens expire after 24h - authorize ALL servers you need <<<${NC}"
    if command opencode mcp auth "$mcp_name"; then
      log_success "Successfully authenticated $mcp_name"
      return 0
    else
      log_error "Failed to authenticate $mcp_name"
      return 1
    fi
  }

  log_info "Starting OpenCode FULL AUTH REFRESH..."
  echo ""

  if ! auth_opencode; then
    log_error "Cannot proceed without OpenCode authentication"
    return 1
  fi

  echo ""
  log_info "Refreshing MCP authentication (logout + login)..."
  echo ""

  local mcp
  for mcp in "${REQUIRED_MCPS[@]}"; do
    logout_mcp "$mcp"
    if ! auth_mcp "$mcp"; then
      log_warn "Continuing despite $mcp authentication failure..."
    fi
    echo ""
  done

  echo ""
  log_success "All authentication checks complete!"
  echo ""

  log_info "Launching OpenCode..."
  command opencode "$@"
}

# opencode: Smart launcher - only re-auths if needed (faster for daily use)
# Use this as your normal command; it checks status before forcing re-auth
opencode() {
  local RED='\033[0;31m'
  local GREEN='\033[0;32m'
  local YELLOW='\033[1;33m'
  local BLUE='\033[0;34m'
  local NC='\033[0m'

  local REQUIRED_MCPS=("cf-portal")

  log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
  log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
  log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
  log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

  get_mcp_status() {
    local mcp_name=$1
    local mcp_list_output
    mcp_list_output=$(command opencode mcp list 2>&1 || true)

    if echo "$mcp_list_output" | grep -A1 "●.*$mcp_name " | grep -q "connected"; then
      echo "connected"
    elif echo "$mcp_list_output" | grep -A1 "●.*$mcp_name " | grep -q "failed"; then
      echo "failed"
    elif echo "$mcp_list_output" | grep -A1 "●.*$mcp_name " | grep -q "disabled"; then
      echo "disabled"
    else
      echo "unknown"
    fi
  }

  auth_mcp() {
    local mcp_name=$1
    log_info "Authenticating MCP: $mcp_name..."
    echo -e "${YELLOW}>>> Click 'Authorize' for EACH server in the browser <<<${NC}"
    if command opencode mcp auth "$mcp_name"; then
      log_success "Successfully authenticated $mcp_name"
      return 0
    else
      log_error "Failed to authenticate $mcp_name"
      return 1
    fi
  }

  log_info "Checking MCP status..."
  
  local needs_auth=()
  local mcp mcp_status

  for mcp in "${REQUIRED_MCPS[@]}"; do
    mcp_status=$(get_mcp_status "$mcp")
    case "$mcp_status" in
      "connected")
        log_success "$mcp is connected"
        ;;
      "failed"|"disabled"|"unknown")
        log_warn "$mcp is $mcp_status - will authenticate"
        needs_auth+=("$mcp")
        ;;
    esac
  done

  if [[ ${#needs_auth[@]} -gt 0 ]]; then
    echo ""
    for mcp in "${needs_auth[@]}"; do
      # Logout first to ensure clean re-auth
      command opencode mcp logout "$mcp" 2>/dev/null || true
      if ! auth_mcp "$mcp"; then
        log_warn "Continuing despite $mcp authentication failure..."
      fi
    done
    echo ""
  fi

  log_info "Launching OpenCode..."
  command opencode "$@"
}

# ocfix: Emergency fix when GitLab (or other servers) show 401 errors mid-session
# Run this without exiting opencode - it refreshes tokens
ocfix() {
  echo -e "\033[1;33m[FIX]\033[0m Refreshing all MCP tokens..."
  command opencode mcp logout cf-portal 2>/dev/null || true
  echo -e "\033[1;33m>>> Click 'Authorize' for EACH server (especially GitLab) <<<\033[0m"
  command opencode mcp auth cf-portal
  echo -e "\033[0;32m[DONE]\033[0m Tokens refreshed. Restart opencode or try your command again."
}

oc-split() {
  local name
  name=$(basename "$(pwd)")
  tmux new-session -d -s "$name" -c "$(pwd)"
  tmux split-window -h -t "$name" "opencode"
  tmux select-pane -t "$name:0.0"
  tmux attach -t "$name"
}
