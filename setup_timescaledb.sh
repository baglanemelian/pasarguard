#!/usr/bin/env bash
# ==============================================================================
# PasarGuard TimescaleDB Setup Script
# Switches PasarGuard to TimescaleDB (PostgreSQL + TimescaleDB Extension)
# ==============================================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

INSTALL_DIR="/opt/pasarguard"

if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}[ERROR] Please run as root (use sudo).${NC}"
    exit 1
fi

echo -e "${CYAN}=== Configuring TimescaleDB for PasarGuard ===${NC}\n"

# 1. Install Docker if missing
if ! command -v docker &>/dev/null; then
    echo -e "${YELLOW}[1/4] Installing Docker for TimescaleDB...${NC}"
    curl -fsSL https://get.docker.com | sh
    systemctl enable --now docker
else
    echo -e "${GREEN}[✓] Docker is already installed.${NC}"
fi

# 2. Start TimescaleDB Container
echo -e "${YELLOW}[2/4] Deploying TimescaleDB (pg16) container...${NC}"
mkdir -p /var/lib/pasarguard/timescaledb

# Generate random secure database password
DB_PASS=$(head -c 24 /dev/urandom | base64 | tr -dc 'a-zA-Z0-9' | head -c 20)

if docker ps -a --format '{{.Names}}' | grep -q "^pasarguard-timescaledb$"; then
    echo -e "${CYAN}Container pasarguard-timescaledb already exists, restarting...${NC}"
    docker restart pasarguard-timescaledb
else
    docker run -d \
        --name pasarguard-timescaledb \
        --restart always \
        -p 127.0.0.1:5432:5432 \
        -e POSTGRES_PASSWORD="${DB_PASS}" \
        -e POSTGRES_DB=pasarguard \
        -v /var/lib/pasarguard/timescaledb:/var/lib/postgresql/data \
        timescale/timescaledb:latest-pg16
fi

echo -e "${CYAN}Waiting for TimescaleDB to become ready...${NC}"
sleep 7

# 3. Update PasarGuard .env configuration
echo -e "${YELLOW}[3/4] Updating PasarGuard database configuration to TimescaleDB...${NC}"
if [ -f "$INSTALL_DIR/.env" ]; then
    sed -i "s|SQLALCHEMY_DATABASE_URL = .*|SQLALCHEMY_DATABASE_URL = \"postgresql+asyncpg://postgres:${DB_PASS}@127.0.0.1:5432/pasarguard\"|" "$INSTALL_DIR/.env"
else
    echo -e "${RED}[ERROR] $INSTALL_DIR/.env not found! Please run the installer first.${NC}"
    exit 1
fi

# 4. Run Alembic Database Migrations
echo -e "${YELLOW}[4/4] Running database migrations on TimescaleDB...${NC}"
cd "$INSTALL_DIR"
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:/usr/local/bin:$PATH"
uv run alembic upgrade head

# 5. Restart PasarGuard service
echo -e "${CYAN}Restarting PasarGuard service...${NC}"
systemctl restart pasarguard
sleep 3

# Generate setup key
NEW_KEY=$(cd "$INSTALL_DIR" && uv run python pasarguard-cli.py generate-temp-key 2>&1 || true)
SERVER_IP=$(curl -s4 ifconfig.me || curl -s4 api.ipify.org || echo "YOUR_SERVER_IP")

echo -e "\n${GREEN}================================================================${NC}"
echo -e "${GREEN}      TIMESCALEDB CONFIGURED SUCCESSFULLY FOR PASARGUARD!       ${NC}"
echo -e "${GREEN}================================================================${NC}"
echo -e "${CYAN}Database URL:${NC} postgresql+asyncpg://postgres:****@127.0.0.1:5432/pasarguard"
echo ""
echo -e "${CYAN}Web Dashboard:${NC} 👉 ${YELLOW}http://${SERVER_IP}:8000/dashboard/${NC}"
echo ""
echo -e "${CYAN}New Administrator Setup Key:${NC}"
echo -e "${NEW_KEY}"
echo -e "${GREEN}================================================================${NC}\n"
