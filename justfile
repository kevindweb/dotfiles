default:
    @just --list

lint: lint-prettier lint-shellcheck

lint-prettier:
    prettier --check "**/*.{json,yaml,yml,md}"

lint-shellcheck:
    find . -type f \( -name "*.sh" -o -name "*.zsh" \) -exec shellcheck {} +
    find . -type f \( -name "*.sh" -o -name "*.zsh" \) -exec shfmt -d -i 2 {} +

fix:
    prettier --write "**/*.{json,yaml,yml,md}"
    find . -type f \( -name "*.sh" -o -name "*.zsh" \) -exec shfmt -w -i 2 {} +

# =============================================================================
# macOS storage cleanup recipes
# =============================================================================

# Run all cleanup tasks (safe ones only)
cleanup: docker-cleanup go-cleanup brew-cleanup npm-cleanup cache-cleanup
    @echo "✓ All cleanup tasks completed"

# Deep cleanup including Wrangler, Codeium, etc (more aggressive)
cleanup-deep: cleanup wrangler-cleanup codeium-cleanup cargo-cleanup go-cleanup-deep
    @echo "✓ Deep cleanup completed"

# Clean Docker images, containers, build cache, and Scout cache (~76GB potential)
docker-cleanup:
    @echo "Cleaning Docker..."
    docker system prune -a --volumes -f
    @echo "Cleaning Docker Scout cache..."
    rm -rf ~/.docker/scout 2>/dev/null || true

# Clean Go build cache only (safe, fast rebuilds)
go-cleanup:
    @echo "Cleaning Go build cache..."
    go clean -cache || sudo rm -rf ~/Library/Caches/go-build

# Clean Go module cache (~28GB potential) - modules re-download on next build
go-cleanup-deep:
    @echo "Cleaning Go module cache..."
    go clean -modcache

# Clean Homebrew cache (~3GB potential)
brew-cleanup:
    @echo "Cleaning Homebrew cache..."
    -brew cleanup --prune=all

# Clean npm cache (~7GB potential)
npm-cleanup:
    @echo "Cleaning npm cache..."
    npm cache clean --force 2>/dev/null || true
    @echo "Cleaning yarn cache..."
    yarn cache clean 2>/dev/null || true

# Clean general caches (~1.3GB potential)
cache-cleanup:
    @echo "Cleaning ~/.cache..."
    rm -rf ~/.cache/pip 2>/dev/null || true
    rm -rf ~/.cache/go-build 2>/dev/null || true
    rm -rf ~/.cache/typescript 2>/dev/null || true

# Clean Wrangler/Cloudflare cache and logs (~12GB potential)
wrangler-cleanup:
    @echo "Cleaning Wrangler cache and logs..."
    rm -rf ~/.wrangler/cache 2>/dev/null || true
    rm -rf ~/.wrangler/tmp 2>/dev/null || true
    rm -rf ~/.wrangler/logs 2>/dev/null || true

# Clean Codeium cache (~1.7GB potential)
codeium-cleanup:
    @echo "Cleaning Codeium cache..."
    rm -rf ~/.codeium/cache 2>/dev/null || true

# Clean Cargo/Rust cache (~1.6GB potential)
cargo-cleanup:
    @echo "Cleaning Cargo cache..."
    cargo cache -a 2>/dev/null || rm -rf ~/.cargo/registry/cache 2>/dev/null || true

# Show current disk usage for common storage hogs
disk-usage:
    @echo "=== Disk Usage Report ==="
    @echo "\nDocker (~76GB):"
    @du -sh ~/.docker 2>/dev/null || echo "Not found"
    @docker system df 2>/dev/null || echo "Docker not running"
    @echo "\nWrangler (~12GB):"
    @du -sh ~/.wrangler 2>/dev/null || echo "Not found"
    @echo "\nNode (nvm + npm) (~17GB):"
    @du -sh ~/.nvm 2>/dev/null || echo "Not found"
    @du -sh ~/.npm 2>/dev/null || echo "Not found"
    @echo "\nGo:"
    @du -sh ~/go 2>/dev/null || echo "Not found"
    @du -sh ~/Library/Caches/go-build 2>/dev/null || echo "No build cache"
    @echo "\nPython (pyenv + virtualenvs) (~3GB):"
    @du -sh ~/.pyenv 2>/dev/null || echo "Not found"
    @du -sh ~/.virtualenvs 2>/dev/null || echo "Not found"
    @echo "\nRust (cargo + rustup) (~2.8GB):"
    @du -sh ~/.cargo 2>/dev/null || echo "Not found"
    @du -sh ~/.rustup 2>/dev/null || echo "Not found"
    @echo "\nAI/IDE tools (~4GB):"
    @du -sh ~/.codeium ~/.continue ~/.claude 2>/dev/null || echo "Not found"
    @echo "\nHomebrew cache:"
    @du -sh ~/Library/Caches/Homebrew 2>/dev/null || echo "Not found"
    @echo "\nGeneral cache:"
    @du -sh ~/.cache 2>/dev/null || echo "Not found"
