<p align="center">
  <a href="https://github.com/baglanemelian/pasarguard" target="_blank" rel="noopener noreferrer">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="https://github.com/PasarGuard/PasarGuard.github.io/raw/main/public/logos/PasarGuard-white-logo.png">
      <img width="160" height="160" src="https://github.com/PasarGuard/PasarGuard.github.io/raw/main/public/logos/PasarGuard-black-logo.png" alt="PasarGuard Logo">
    </picture>
  </a>
</p>

<h1 align="center">🛡️ PasarGuard</h1>

<p align="center">
  <strong>Unified, Censorship-Resistant Multi-Node Proxy Orchestration & Management Platform</strong>
</p>

<p align="center">
  <a href="https://github.com/baglanemelian/pasarguard"><img src="https://img.shields.io/badge/Python-3.14-3776AB?style=for-the-badge&logo=python&logoColor=white" alt="Python 3.14"></a>
  <a href="https://github.com/baglanemelian/pasarguard"><img src="https://img.shields.io/badge/FastAPI-0.115+-009688?style=for-the-badge&logo=fastapi&logoColor=white" alt="FastAPI"></a>
  <a href="https://github.com/baglanemelian/pasarguard"><img src="https://img.shields.io/badge/React-19-61DAFB?style=for-the-badge&logo=react&logoColor=black" alt="React 19"></a>
  <a href="https://github.com/baglanemelian/pasarguard"><img src="https://img.shields.io/badge/TypeScript-5.x-3178C6?style=for-the-badge&logo=typescript&logoColor=white" alt="TypeScript"></a>
  <a href="https://github.com/baglanemelian/pasarguard"><img src="https://img.shields.io/badge/Tailwind_CSS-v4-06B6D4?style=for-the-badge&logo=tailwindcss&logoColor=white" alt="Tailwind CSS"></a>
  <a href="https://github.com/baglanemelian/pasarguard"><img src="https://img.shields.io/badge/Docker-Ready-2496ED?style=for-the-badge&logo=docker&logoColor=white" alt="Docker Ready"></a>
  <a href="https://github.com/baglanemelian/pasarguard/blob/main/LICENSE"><img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" alt="License MIT"></a>
</p>

<p align="center">
  <a href="./README-fa.md">🇮🇷 فارسی</a> •
  <a href="./README-zh-cn.md">🇨🇳 简体中文</a> •
  <a href="./README-ru.md">🇷🇺 Русский</a>
</p>

<p align="center">
  <img src="https://github.com/PasarGuard/PasarGuard.github.io/raw/main/public/logos/screenshot.png" alt="PasarGuard Dashboard Preview" width="900" style="border-radius: 12px; box-shadow: 0 10px 30px rgba(0,0,0,0.35);">
</p>

---

## 📋 Table of Contents

- [📖 Overview](#-overview)
- [✨ Key Features](#-key-features)
- [💎 Custom Enhancements in this Fork](#-custom-enhancements-in-this-fork)
- [⚙️ System Requirements](#️-system-requirements)
- [🚀 Detailed Installation & Setup Guide](#-detailed-installation--setup-guide)
  - [Method 1: Production Linux VPS Deployment (Automated Script)](#method-1-production-linux-vps-deployment-automated-script)
  - [Method 2: Docker & Docker Compose Deployment](#method-2-docker--docker-compose-deployment)
  - [Method 3: Native Windows Setup (Local Development & Testing)](#method-3-native-windows-setup-local-development--testing)
  - [Method 4: Manual Linux/Ubuntu Source Installation](#method-4-manual-linuxubuntu-source-installation)
- [🔑 First-Time Setup & Admin Account Creation](#-first-time-setup--admin-account-creation)
- [🌐 Service Ports & Access Addresses](#-service-ports--access-addresses)
- [⚙️ Configuration & Environment Variables (.env)](#️-configuration--environment-variables-env)
- [🛡️ Advanced Capabilities](#️-advanced-capabilities)
  - [Concurrent IP Limiter (UUID Security)](#concurrent-ip-limiter-uuid-security)
  - [Reseller & Sub-Admin User Quota](#reseller--sub-admin-user-quota)
  - [Telegram Bot & System Alerts](#telegram-bot--system-alerts)
- [🏗️ System Architecture](#️-system-architecture)
- [❓ Troubleshooting & FAQ](#-troubleshooting--faq)
- [🤝 Contributing](#-contributing)
- [📄 License](#-license)

---

## 📖 Overview

**PasarGuard** is an enterprise-grade, high-performance proxy management panel designed for seamless orchestration of censorship-resistant protocols. Built on top of **FastAPI (Python 3.14)** and **React 19**, PasarGuard enables administrators to manage thousands of active client credentials, distributed multi-core nodes, granular billing metrics, and hardware-bound access limitations from a unified, modern web interface.

Supported cores & protocols:
- **Xray-core & Sing-box:** VLESS, VMess, Trojan, Shadowsocks, Hysteria 2, TUIC
- **WireGuard:** Direct peer provisioning and key generation
- **Security Protocols:** REALITY, Vision, gRPC, WebSocket, TCP, HTTP/2, TLS 1.3

---

## ✨ Key Features

<table>
  <tr>
    <td width="50%">
      <h3>🔒 Multi-Protocol & Multi-Core</h3>
      Native support for <b>Xray-core</b>, <b>Sing-box</b>, and <b>WireGuard</b>. Configure single-port multi-inbound fallbacks, TLS, and REALITY camouflage.
    </td>
    <td width="50%">
      <h3>⚡ Concurrent IP Limit (UUID Level)</h3>
      Real-time background security engine that inspects active client IP connections per UUID and instantly terminates unauthorized credential sharing.
    </td>
  </tr>
  <tr>
    <td width="50%">
      <h3>👥 Multi-Admin & Reseller Quotas</h3>
      Granular Role-Based Access Control (RBAC). Assign sub-admins and resellers strict user quotas (<code>max_users</code>) and permission scopes.
    </td>
    <td width="50%">
      <h3>📊 Live Telemetry & Node Health</h3>
      Sub-second live bandwidth gauges, memory/CPU usage, active connections, node ping status, and historical data usage charts powered by Recharts.
    </td>
  </tr>
  <tr>
    <td width="50%">
      <h3>🔗 Universal Subscription Delivery</h3>
      Auto-generates subscription links and QR codes compatible with <b>V2rayNG</b>, <b>Clash Meta / Mihomo</b>, <b>Sing-box</b>, <b>Shadowrocket</b>, and <b>Streisand</b>.
    </td>
    <td width="50%">
      <h3>🤖 Telegram Bot & Webhook Automations</h3>
      Automated backup dispatch, low balance / traffic expiration warnings, server offline alerts, and subscription renewal notifications.
    </td>
  </tr>
</table>

---

## 💎 Custom Enhancements in this Fork

This repository contains custom production enhancements and bugfixes:

- [x] **Concurrent IP Multi-Device Limiter (`uuid_limit`):** Added database schema migrations, UI inputs in user create/edit dialogs, and a background daemon (`ip_limit_checker.py`) that monitors multi-IP abusers.
- [x] **Sub-Admin / Reseller Quota Enforcement (`max_users`):** Built-in backend validation preventing resellers from creating more users than their allocated limit.
- [x] **Full Windows Native Support:** Windows compatibility fixes, pre-configured launcher scripts (`start-all.bat`), and async SQLite database support.
- [x] **Zero-CORS Vite Reverse Proxy:** Configured single-origin reverse proxy for development, preventing Private Network Access (PNA) blockages.

---

## ⚙️ System Requirements

### Production Server (Linux VPS)
- **OS:** Ubuntu 22.04 LTS / 24.04 LTS or Debian 12 (Recommended)
- **CPU:** 1 Core minimum (2+ Cores recommended for high traffic)
- **RAM:** 1 GB minimum (2 GB+ recommended)
- **Disk:** 10 GB free SSD storage
- **Network:** Static Public IPv4 / IPv6, ports `80`, `443`, and `8000` accessible

### Local Development (Windows / macOS / Linux)
- **Python:** 3.12+ (3.14 via `uv` recommended)
- **Node.js & Runtime:** Node.js 20+ and [Bun](https://bun.sh) (v1.1+)
- **Package Managers:** `uv` (Fast Python package manager) and `git`

---

## 🚀 Detailed Installation & Setup Guide

### Method 1: Production Linux VPS Deployment (Automated Script)

The easiest and fastest method to install PasarGuard on a Linux server is using the automated installer.

#### Step 1: Connect to your VPS
```bash
ssh root@YOUR_SERVER_IP
```

#### Step 2: Update system packages
```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl wget git
```

#### Step 3: Run the installer script
Choose your preferred database backend:

**Option A — SQLite (Best for single-server or small setups):**
```bash
sudo bash -c "$(curl -fsSL https://github.com/PasarGuard/scripts/raw/main/pasarguard.sh)" @ install
```

**Option B — TimescaleDB / PostgreSQL (Recommended for high volume and multi-node clusters):**
```bash
sudo bash -c "$(curl -fsSL https://github.com/PasarGuard/scripts/raw/main/pasarguard.sh)" @ install --database timescaledb
```

#### Step 4: Verify the installation & services
```bash
# Check service status
systemctl status pasarguard

# View live service logs
journalctl -u pasarguard -f
```

---

### Method 2: Docker & Docker Compose Deployment

Running PasarGuard inside Docker ensures an isolated and predictable environment.

#### Step 1: Install Docker and Docker Compose
```bash
curl -fsSL https://get.docker.com | sh
sudo systemctl enable --now docker
```

#### Step 2: Clone the repository
```bash
git clone https://github.com/baglanemelian/pasarguard.git /opt/pasarguard
cd /opt/pasarguard
```

#### Step 3: Configure Environment Variables
Copy the sample environment file and adjust your settings:
```bash
cp .env.example .env
nano .env
```
*(Make sure to set your secure secret keys, database URL, and domain).*

#### Step 4: Launch the container
```bash
docker compose up -d
```

#### Step 5: Check container status & logs
```bash
docker compose ps
docker compose logs -f
```

---

### Method 3: Native Windows Setup (Local Development & Testing)

You can run PasarGuard natively on Windows without Docker or WSL.

#### Step 1: Install Required Tools
Ensure you have the following installed:
1. **Git:** Download and install from [git-scm.com](https://git-scm.com/)
2. **uv (Python Package Manager):**
   Open PowerShell and run:
   ```powershell
   powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
   ```
3. **Bun (JavaScript Runtime & Bundler):**
   Open PowerShell and run:
   ```powershell
   powershell -c "irm bun.sh/install.ps1 | iex"
   ```

#### Step 2: Clone the Repository
```powershell
git clone https://github.com/baglanemelian/pasarguard.git
cd pasarguard
```

#### Step 3: Install Backend Dependencies
```powershell
# Create virtual environment and sync all dependencies
uv sync
```

#### Step 4: Run Database Migrations
```powershell
uv run alembic upgrade head
```

#### Step 5: Install Frontend Dependencies
```powershell
cd dashboard
bun install
cd ..
```

#### Step 6: One-Click Launch
Double-click `start-all.bat` or run:
```bat
start-all.bat
```
This will launch:
- **Backend API Server:** `http://127.0.0.1:8000`
- **Frontend Dev Server (with Hot Module Replacement):** `http://localhost:5173`

*(Individual launchers `run-backend.bat`, `run-frontend-dev.bat`, and `build-frontend.bat` are also available).*

---

### Method 4: Manual Linux/Ubuntu Source Installation

#### Step 1: Install Python, uv, and System Dependencies
```bash
sudo apt update
sudo apt install -y python3 python3-pip curl git build-essential

# Install uv package manager
curl -LsSf https://astral.sh/uv/install.sh | sh
source ~/.cargo/env
```

#### Step 2: Clone the Repository
```bash
git clone https://github.com/baglanemelian/pasarguard.git /opt/pasarguard
cd /opt/pasarguard
```

#### Step 3: Set Up Environment & Install Packages
```bash
cp .env.example .env
uv sync
uv run alembic upgrade head
```

#### Step 4: Build Frontend Assets
```bash
# Install Bun
curl -fsSL https://bun.sh/install | bash
source ~/.bashrc

cd dashboard
bun install
bun run build
cd ..
```

#### Step 5: Run the Server
```bash
uv run python main.py
```

---

## 🔑 First-Time Setup & Admin Account Creation

When you install PasarGuard for the first time, you must create the initial **Owner (Superadmin)** account.

### Step 1: Generate a Temporary Setup Key
Run the following CLI command inside the project directory:

**On Linux / Docker:**
```bash
# Direct Python / uv
uv run python pasarguard-cli.py generate-temp-key

# Or via Docker
docker compose exec pasarguard pasarguard-cli generate-temp-key
```

**On Windows:**
```powershell
uv run python pasarguard-cli.py generate-temp-key
```

Output example:
```
==================================================
  PasarGuard Setup Key:  pg_setup_9f82ab47c1e8
  Valid for: 15 minutes
==================================================
```

### Step 2: Complete Setup in Browser
1. Open your browser and navigate to:
   - Development: `http://localhost:5173/login`
   - Production: `http://YOUR_SERVER_IP:8000/dashboard/`
2. Click **"Use Setup Key"** or paste the generated key into the prompt.
3. Define your master **Username** and **Password**.
4. You are now logged in as the **Owner** with full administrative privileges!

---

## 🌐 Service Ports & Access Addresses

| Component | Default Address | Description |
|---|---|---|
| **Admin Dashboard (Dev)** | `http://localhost:5173` | Vite development server with instant Hot Module Replacement (HMR) |
| **Admin Dashboard (Prod)** | `http://127.0.0.1:8000/dashboard/` | Compiled production dashboard served by FastAPI |
| **Interactive API Documentation** | `http://127.0.0.1:8000/docs` | Swagger UI with live API testing endpoints |
| **OpenAPI Specification** | `http://127.0.0.1:8000/openapi.json` | Raw OpenAPI JSON schema definition |
| **Client Subscriptions** | `http://127.0.0.1:8000/sub/{token}` | Dynamic subscription endpoint for V2ray/Clash/Sing-box clients |

---

## ⚙️ Configuration & Environment Variables (.env)

The `.env` file at the root of the project controls core behaviors:

```ini
## Server Binding
UVICORN_HOST = "0.0.0.0"       # Set to 127.0.0.1 for local/reverse-proxy setups
UVICORN_PORT = 8000            # Port for FastAPI application

## Application Role
ROLE = "all-in-one"            # Options: 'all-in-one', 'master', 'node'

## Debugging & Documentation
DEBUG = False                  # Set to True for verbose tracebacks
DOCS = True                    # Enable/Disable /docs and /redoc endpoints

## Database Connection
# SQLite:
SQLALCHEMY_DATABASE_URL = "sqlite+aiosqlite:///db.sqlite3"
# PostgreSQL:
# SQLALCHEMY_DATABASE_URL = "postgresql+asyncpg://user:pass@localhost:5432/pasarguard"

## Security & Authentication
JWT_SECRET_KEY = "generate-a-strong-random-string-here"
ACCESS_TOKEN_EXPIRE_MINUTES = 1440

## CORS Configuration
ALLOWED_ORIGINS = "*"

## Telegram Bot Integration (Optional)
TELEGRAM_BOT_TOKEN = ""
TELEGRAM_ADMIN_CHAT_ID = ""
```

---

## 🛡️ Advanced Capabilities

### Concurrent IP Limiter (UUID Security)
Prevent credential sharing and multi-device abuse on subscription links:
1. Navigate to **Users** ➔ Click **Create User** (or Edit existing).
2. Set the **IP Limit** field (e.g., `1` for single device, `2` for dual device).
3. The background monitor automatically detects active IPs across inbounds and temporarily restricts access when the threshold is exceeded.

### Reseller & Sub-Admin User Quota
Scale your proxy infrastructure with delegated resellers:
1. Navigate to **Admins** ➔ **Create Admin**.
2. Assign the **Reseller** role.
3. Configure the **User Quota (`max_users`)** (e.g., `50`).
4. The reseller can create, manage, and monitor their own users up to their assigned limit without seeing users belonging to other resellers or the master administrator.

### Telegram Bot & System Alerts
Receive real-time mission-critical alerts:
- **Node Status:** Instant notifications when a proxy node loses connectivity.
- **Traffic Warnings:** Client notifications when 80% and 100% of data limits are reached.
- **Automated Backups:** Daily encrypted database backups sent straight to your private Telegram chat.

---

## 🏗️ System Architecture

```mermaid
graph TD
    User([End User / Proxy Client]) -->|VLESS / VMess / WireGuard| Node[Proxy Edge Node]
    Admin([Administrator / Reseller]) -->|HTTPS / Dashboard UI| Gateway[Nginx / Reverse Proxy]
    
    Gateway -->|Port 8000| Core[PasarGuard FastAPI Core]
    
    subgraph Core Services
        Core --> Auth[RBAC & JWT Auth]
        Core --> IPLimiter[UUID Concurrent IP Inspector]
        Core --> Scheduler[APScheduler Background Jobs]
        Core --> DB[(Database: SQLite / PostgreSQL)]
    end
    
    subgraph Distributed Nodes
        Core -->|gRPC / REST API| MasterNode[Master Xray Node]
        Core -->|TLS / SSH| EdgeNode1[Sing-box Edge Node]
        Core -->|WireGuard Protocol| EdgeNode2[WireGuard Endpoint]
    end
```

---

## ❓ Troubleshooting & FAQ

<details>
<summary><b>1. Port 8000 or 5173 is already in use</b></summary>
If another service is using port 8000 or 5173:
- In `.env`, change `UVICORN_PORT = 8001`.
- For the frontend, run `bun run dev --port 5174`.
</details>

<details>
<summary><b>2. Database schema is out of date / Migration errors</b></summary>
Run the database migrations:
```bash
uv run alembic upgrade head
```
</details>

<details>
<summary><b>3. Cannot access dashboard from external IP</b></summary>
Ensure your firewall allows incoming traffic on port 8000:
```bash
sudo ufw allow 8000/tcp
```
Make sure `UVICORN_HOST = "0.0.0.0"` in `.env`.
</details>

<details>
<summary><b>4. How to reset admin password?</b></summary>
Generate a new setup key via CLI:
```bash
uv run python pasarguard-cli.py generate-temp-key
```
Use the key on the login page to reset credentials.
</details>

---

## 🤝 Contributing

Contributions are warmly welcomed! To contribute:
1. Fork this repository.
2. Create a feature branch: `git checkout -b feature/amazing-feature`.
3. Commit your changes: `git commit -m 'feat: add amazing feature'`.
4. Push to your branch: `git push origin feature/amazing-feature`.
5. Open a **Pull Request**.

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).  
Developed with ❤️ for censorship-free, open, and secure internet access.
