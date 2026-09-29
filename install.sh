#!/usr/bin/env bash
# ==============================================================================
# PasarGuard Automated Linux VPS Installer
# Repository: https://github.com/baglanemelian/pasarguard
# ==============================================================================

set -e

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

INSTALL_DIR="/opt/pasarguard"
REPO_URL="https://github.com/baglanemelian/pasarguard.git"

echo -e "${CYAN}"
echo "  ____                              ____                         _ "
echo " |  _ \ __ _ ___  __ _ _ __ / ___|_   _  __ _ _ __ __| |"
echo " | |_) / _\` / __|/ _\` | '__| |  _| | | |/ _\` | '__/ _\` |"
echo " |  __/ (_| \__ \ (_| | |  | |_| | |_| | (_| | | | (_| |"
echo " |_|   \__,_|___/\__,_|_|   \____|\__,_|\__,_|_|  \__,_|"
echo -e "${NC}"
echo -e "${BLUE}=== PasarGuard Next-Gen Linux VPS Installer ===${NC}\n"

# 1. Root Check
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}[ERROR] Please run this script as root (use sudo).${NC}"
    exit 1
fi

# 2. Update package index and install prerequisites
echo -e "${YELLOW}[1/7] Updating system packages & installing core dependencies...${NC}"
if command -v apt-get &>/dev/null; then
    apt-get update -y
    apt-get install -y curl wget git build-essential python3 python3-pip ca-certificates
elif command -v dnf &>/dev/null; then
    dnf update -y
    dnf install -y curl wget git gcc gcc-c++ make python3 python3-pip ca-certificates
elif command -v yum &>/dev/null; then
    yum update -y
    yum install -y curl wget git gcc gcc-c++ make python3 python3-pip ca-certificates
fi

# 3. Install uv (Fast Python Package Manager) if missing
echo -e "${YELLOW}[2/7] Checking and installing uv Python package manager...${NC}"
if ! command -v uv &>/dev/null; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.cargo/bin:$PATH"
    if [ -f "$HOME/.cargo/env" ]; then
        source "$HOME/.cargo/env"
    fi
fi

# 4. Install Bun (JavaScript runtime for dashboard) if missing
echo -e "${YELLOW}[3/7] Checking and installing Bun runtime...${NC}"
if ! command -v bun &>/dev/null; then
    curl -fsSL https://bun.sh/install | bash
    export BUN_INSTALL="$HOME/.bun"
    export PATH="$BUN_INSTALL/bin:$PATH"
    if [ -f "$HOME/.bashrc" ]; then
        source "$HOME/.bashrc"
    fi
fi

# Ensure binaries are available in PATH
export PATH="$HOME/.cargo/bin:$HOME/.bun/bin:/usr/local/bin:$PATH"

# 5. Clone or update repository in /opt/pasarguard
echo -e "${YELLOW}[4/7] Deploying PasarGuard source code into ${INSTALL_DIR}...${NC}"
if [ -d "$INSTALL_DIR/.git" ]; then
    echo -e "${CYAN}Directory exists, pulling latest updates...${NC}"
    cd "$INSTALL_DIR"
    git reset --hard HEAD
    git pull origin main
else
    mkdir -p "$INSTALL_DIR"
    git clone "$REPO_URL" "$INSTALL_DIR"
    cd "$INSTALL_DIR"
fi

# 6. Configure environment (.env)
echo -e "${YELLOW}[5/7] Configuring environment variables...${NC}"
if [ ! -f "$INSTALL_DIR/.env" ]; then
    cp "$INSTALL_DIR/.env.example" "$INSTALL_DIR/.env"
    # Generate random JWT secret
    RANDOM_SECRET=$(head -c 32 /dev/urandom | base64 | tr -dc 'a-zA-Z0-9' | head -c 32)
    sed -i "s/JWT_SECRET_KEY = .*/JWT_SECRET_KEY = \"${RANDOM_SECRET}\"/" "$INSTALL_DIR/.env"
    sed -i 's/UVICORN_HOST = .*/UVICORN_HOST = "0.0.0.0"/' "$INSTALL_DIR/.env"
fi

# 7. Install Python dependencies and run database migrations
echo -e "${YELLOW}[6/7] Installing Python backend packages & running database migrations...${NC}"
cd "$INSTALL_DIR"
uv sync
uv run alembic upgrade head

# 8. Build Frontend Dashboard
echo -e "${YELLOW}[7/7] Compiling Frontend Dashboard assets...${NC}"
cd "$INSTALL_DIR/dashboard"
bun install
VITE_BASE_API=/ bun run build
cp -f ./build/index.html ./build/404.html || true
cd "$INSTALL_DIR"

# 9. Register systemd service
echo -e "${YELLOW}[+] Registering Linux systemd service (pasarguard.service)...${NC}"
SERVICE_FILE="/etc/systemd/system/pasarguard.service"
cat > "$SERVICE_FILE" <<EOF
[Unit]
Description=PasarGuard Proxy Orchestration Panel
Documentation=https://github.com/baglanemelian/pasarguard
After=network.target nss-lookup.target

[Service]
Type=simple
User=root
WorkingDirectory=${INSTALL_DIR}
ExecStart=${INSTALL_DIR}/.venv/bin/python3 ${INSTALL_DIR}/main.py
Restart=always
RestartSec=5
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable pasarguard
systemctl restart pasarguard

# 10. Open firewall port if ufw is active
if command -v ufw &>/dev/null && ufw status | grep -q "Status: active"; then
    echo -e "${CYAN}[+] Opening firewall port 8000/tcp...${NC}"
    ufw allow 8000/tcp || true
fi

# Wait for server to warm up
sleep 3

# 11. Generate setup key for owner account
echo -e "\n${CYAN}[+] Generating one-time administrator setup key...${NC}"
TEMP_KEY=$(cd "$INSTALL_DIR" && uv run python pasarguard-cli.py generate-temp-key 2>&1 || true)

# Detect public IP
SERVER_IP=$(curl -s4 ifconfig.me || curl -s4 api.ipify.org || echo "YOUR_SERVER_IP")

echo -e "\n${GREEN}================================================================${NC}"
echo -e "${GREEN}      PASARGUARD INSTALLATION COMPLETED SUCCESSFULLY!           ${NC}"
echo -e "${GREEN}================================================================${NC}"
echo -e "${CYAN}Access your panel dashboard:${NC}"
echo -e "  👉  ${YELLOW}http://${SERVER_IP}:8000/dashboard/${NC}"
echo -e "  👉  ${YELLOW}http://${SERVER_IP}:8000/docs${NC} (Swagger REST API)"
echo ""
echo -e "${CYAN}Administrator Setup Key:${NC}"
echo -e "${TEMP_KEY}"
echo ""
echo -e "${CYAN}Service Management Commands:${NC}"
echo -e "  - Status:   ${YELLOW}sudo systemctl status pasarguard${NC}"
echo -e "  - Restart:  ${YELLOW}sudo systemctl restart pasarguard${NC}"
echo -e "  - Logs:     ${YELLOW}sudo journalctl -u pasarguard -f${NC}"
echo -e "${GREEN}================================================================${NC}\n"
