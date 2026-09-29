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

# 2. Update package index and install prerequisites (including unzip and tar)
echo -e "${YELLOW}[1/7] Updating system packages & installing core dependencies...${NC}"
if command -v apt-get &>/dev/null; then
    apt-get update -y
    apt-get install -y curl wget git build-essential python3 python3-pip ca-certificates unzip tar
elif command -v dnf &>/dev/null; then
    dnf update -y
    dnf install -y curl wget git gcc gcc-c++ make python3 python3-pip ca-certificates unzip tar
elif command -v yum &>/dev/null; then
    yum update -y
    yum install -y curl wget git gcc gcc-c++ make python3 python3-pip ca-certificates unzip tar
fi

# 3. Install uv (Fast Python Package Manager) if missing
echo -e "${YELLOW}[2/7] Checking and installing uv Python package manager...${NC}"
if ! command -v uv &>/dev/null; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
fi

# Add uv to PATH and symlink to /usr/local/bin for global access
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
if [ -f "$HOME/.local/bin/uv" ]; then
    ln -sf "$HOME/.local/bin/uv" /usr/local/bin/uv
    ln -sf "$HOME/.local/bin/uvx" /usr/local/bin/uvx 2>/dev/null || true
elif [ -f "$HOME/.cargo/bin/uv" ]; then
    ln -sf "$HOME/.cargo/bin/uv" /usr/local/bin/uv
    ln -sf "$HOME/.cargo/bin/uvx" /usr/local/bin/uvx 2>/dev/null || true
fi

# 4. Install Bun (JavaScript runtime for dashboard) if missing
echo -e "${YELLOW}[3/7] Checking and installing Bun runtime...${NC}"
if ! command -v bun &>/dev/null; then
    curl -fsSL https://bun.sh/install | bash
fi

# Add Bun to PATH and symlink to /usr/local/bin for global access
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
if [ -f "$HOME/.bun/bin/bun" ]; then
    ln -sf "$HOME/.bun/bin/bun" /usr/local/bin/bun
fi

# Verify tools
export PATH="/usr/local/bin:$HOME/.local/bin:$HOME/.bun/bin:$PATH"
echo -e "${GREEN}[✓] uv version:  $(uv --version)${NC}"
echo -e "${GREEN}[✓] bun version: $(bun --version)${NC}"

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

# Parse database option (default: sqlite, supported: timescaledb / sqlite)
DATABASE_TYPE="sqlite"
for arg in "$@"; do
    if [[ "$arg" == *"timescale"* ]]; then
        DATABASE_TYPE="timescaledb"
    fi
done

# 6. Configure environment (.env)
echo -e "${YELLOW}[5/7] Configuring environment variables (Database: ${DATABASE_TYPE})...${NC}"
if [ ! -f "$INSTALL_DIR/.env" ]; then
    cp "$INSTALL_DIR/.env.example" "$INSTALL_DIR/.env"
    RANDOM_SECRET=$(head -c 32 /dev/urandom | base64 | tr -dc 'a-zA-Z0-9' | head -c 32)
    sed -i "s/JWT_SECRET_KEY = .*/JWT_SECRET_KEY = \"${RANDOM_SECRET}\"/" "$INSTALL_DIR/.env"
    sed -i 's/UVICORN_HOST = .*/UVICORN_HOST = "0.0.0.0"/' "$INSTALL_DIR/.env"
fi

if [ "$DATABASE_TYPE" = "timescaledb" ]; then
    echo -e "${YELLOW}[+] Deploying TimescaleDB container (PostgreSQL + TimescaleDB)...${NC}"
    if ! command -v docker &>/dev/null; then
        echo -e "${CYAN}[+] Installing Docker...${NC}"
        curl -fsSL https://get.docker.com | sh
        systemctl enable --now docker
    fi

    DB_PASS=$(head -c 24 /dev/urandom | base64 | tr -dc 'a-zA-Z0-9' | head -c 20)
    mkdir -p /var/lib/pasarguard/timescaledb

    if ! docker ps -a --format '{{.Names}}' | grep -q "^pasarguard-timescaledb$"; then
        docker run -d \
            --name pasarguard-timescaledb \
            --restart always \
            -p 127.0.0.1:5432:5432 \
            -e POSTGRES_PASSWORD="${DB_PASS}" \
            -e POSTGRES_DB=pasarguard \
            -v /var/lib/pasarguard/timescaledb:/var/lib/postgresql/data \
            timescale/timescaledb:latest-pg16
        echo -e "${CYAN}[+] Waiting for TimescaleDB to initialize...${NC}"
        sleep 6
    fi

    sed -i "s|SQLALCHEMY_DATABASE_URL = .*|SQLALCHEMY_DATABASE_URL = \"postgresql+asyncpg://postgres:${DB_PASS}@127.0.0.1:5432/pasarguard\"|" "$INSTALL_DIR/.env"
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
Environment="PATH=${INSTALL_DIR}/.venv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
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

# 10. Install global 'pasarguard' CLI command
echo -e "${YELLOW}[+] Installing 'pasarguard' command to /usr/local/bin/pasarguard...${NC}"
cp -f "${INSTALL_DIR}/pasarguard.sh" /usr/local/bin/pasarguard
chmod +x /usr/local/bin/pasarguard

# 11. Open firewall port if ufw is active
if command -v ufw &>/dev/null && ufw status | grep -q "Status: active"; then
    echo -e "${CYAN}[+] Opening firewall port 8000/tcp...${NC}"
    ufw allow 8000/tcp || true
fi

# Wait for server to warm up
sleep 3

# 12. Generate setup key for owner account
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
echo -e "${CYAN}PasarGuard Management Commands:${NC}"
echo -e "  - Status:   ${YELLOW}pasarguard status${NC}"
echo -e "  - Restart:  ${YELLOW}pasarguard restart${NC}"
echo -e "  - Logs:     ${YELLOW}pasarguard logs${NC}"
echo -e "  - New Key:  ${YELLOW}pasarguard key${NC}"
echo -e "  - Help:     ${YELLOW}pasarguard${NC}"
echo -e "${GREEN}================================================================${NC}\n"
