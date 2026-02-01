# =============================================================================
# PROJECT SHORTCUTS
# =============================================================================
alias oncall="~/Documents/code/mcs/scripts/util/oncall_start.sh"
alias release="cd ~/Documents/code/release-manager && clear"
alias slo="cd ~/Documents/code/slo && clear"
alias obs="cd ~/Documents/code/obs && clear"
alias precompute="cd ~/Documents/code/slo/sli-precompute && clear"
alias batch="~/Documents/code/release-manager/temporal/workflow/arbitrator/batch/experiments/run_batch.py"
alias snapshot="~/Documents/code/release-manager/temporal/workflow/arbitrator/batch/experiments/cache/snapshot.py"
alias slop="~/Documents/code/release-manager/temporal/workflow/arbitrator/batch/experiments/slo.py"
alias realtest="~/Documents/code/release-manager/temporal/workflow/arbitrator/realtimetest/experiments/run_realtest.py"
alias discrepancy="~/Documents/code/release-manager/temporal/workflow/arbitrator/batch/experiments/discrepancy.py"
alias arbitrator="cd ~/Documents/code/release-arbitrator && clear"
alias watcher="cd ~/Documents/code/release-watcher && clear"
alias provision="cd ~/Documents/code/provisionapi && clear"
alias prov="cd ~/Documents/code/provisionapi && clear"
alias salt="cd ~/Documents/code/salt && clear"
alias dummy="cd ~/Documents/code/dummy && clear"
alias coding="cd ~/Documents/code"
alias notes="cd ~/Notes"

# Release Manager
alias rmup="go run mage.go cluster:up"
alias rmdown="go run mage.go cluster:down"
alias rmclean="sudo go run mage.go cluster:down && sudo go run mage.go clean:all"
alias rmrestart="rmclean && rmup"
alias readability="go run mage.go test:validatereadability"
alias rmvalidate="go run mage.go test:validate && readability"
alias gtest="go test ./..."
alias grace="go clean --testcache && go list ./... | grep -v scripts/temporal | xargs go test -race"
alias deploy="./scripts/deploy/master.sh"

# Provision API
alias provunit="go test -json -short code.cfops.it/devops/provisionapi/v3/api"
alias provintegration="prov && cd integration && docker-compose up --build --exit-code-from go-tests"
