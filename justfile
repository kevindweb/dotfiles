default:
    @just --list

lint: lint-prettier lint-shellcheck

lint-prettier:
    prettier --check "**/*.{json,yaml,yml,md}"

lint-shellcheck:
    find . -type f -name "*.sh" -exec shellcheck {} +

fix:
    prettier --write "**/*.{json,yaml,yml,md}"
