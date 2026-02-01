# =============================================================================
# KUBERNETES
# =============================================================================
alias k="kubectl"

kns() {
  ns="${1:-release-manager-staging}"
  kubie ns "$ns"
}

klogin() {
  kubie ctx cfctl-pdx-c
  kns
}

klogina() {
  kubie ctx cfctl-ams-a
  kns
}

kloginb() {
  kubie ctx cfctl-pdx-b
  kns
}

# Non-interactive kubernetes commands for scripts/agents
kexec() {
  local ctx="${KUBE_CTX:-cfctl-pdx-c}"
  local ns="${KUBE_NS:-release-manager-staging}"
  kubie exec "$ctx" "$ns" kubectl "$@"
}

kexeca() {
  KUBE_CTX=cfctl-ams-a kexec "$@"
}

kexecb() {
  KUBE_CTX=cfctl-pdx-b kexec "$@"
}
