#!/usr/bin/env bash
# ==============================================================================
# PasarGuard System Command Wrapper
# Usage: pasarguard <command>
# ==============================================================================

INSTALL_DIR="/opt/pasarguard"

# Check root for service management commands
require_root() {
    if [ "$EUID" -ne 0 ]; then
        echo "Please run as root (use sudo pasarguard ...)"
        exit 1
    fi
}

case "$1" in
    logs)
        shift
        journalctl -u pasarguard -f "$@"
        ;;
    status)
        systemctl status pasarguard
        ;;
    start)
        require_root
        systemctl start pasarguard
        echo "PasarGuard started."
        ;;
    stop)
        require_root
        systemctl stop pasarguard
        echo "PasarGuard stopped."
        ;;
    restart)
        require_root
        systemctl restart pasarguard
        echo "PasarGuard restarted."
        ;;
    update)
        require_root
        echo "Updating PasarGuard to latest version..."
        cd "$INSTALL_DIR" || exit 1
        git reset --hard HEAD
        git pull origin main
        export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$HOME/.bun/bin:/usr/local/bin:$PATH"
        uv sync
        uv run alembic upgrade head
        cd "$INSTALL_DIR/dashboard" || exit 1
        bun install
        VITE_BASE_API=/ bun run build
        cp -f ./build/index.html ./build/404.html || true
        cd "$INSTALL_DIR" || exit 1
        systemctl restart pasarguard
        echo "PasarGuard updated and restarted successfully!"
        ;;
    cli)
        shift
        cd "$INSTALL_DIR" || exit 1
        export PATH="$HOME/.local/bin:$HOME/.cargo/bin:/usr/local/bin:$PATH"
        uv run python pasarguard-cli.py "$@"
        ;;
    key|generate-temp-key)
        cd "$INSTALL_DIR" || exit 1
        export PATH="$HOME/.local/bin:$HOME/.cargo/bin:/usr/local/bin:$PATH"
        uv run python pasarguard-cli.py generate-temp-key
        ;;
    version)
        cd "$INSTALL_DIR" || exit 1
        export PATH="$HOME/.local/bin:$HOME/.cargo/bin:/usr/local/bin:$PATH"
        uv run python pasarguard-cli.py version
        ;;
    *)
        echo "PasarGuard Management CLI"
        echo ""
        echo "Usage: pasarguard <command>"
        echo ""
        echo "Commands:"
        echo "  pasarguard logs                 Follow live system logs"
        echo "  pasarguard status               Check service status"
        echo "  pasarguard restart              Restart PasarGuard service"
        echo "  pasarguard start                Start PasarGuard service"
        echo "  pasarguard stop                 Stop PasarGuard service"
        echo "  pasarguard key                  Generate a new admin setup key"
        echo "  pasarguard cli <args>           Run internal CLI commands"
        echo "  pasarguard update               Pull latest updates and rebuild"
        echo "  pasarguard version              Show installed version"
        ;;
esac
