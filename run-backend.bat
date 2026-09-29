@echo off
echo ==============================================
echo   PasarGuard Backend Baslatiliyor (Port 8000)...
echo ==============================================
cd /d %~dp0
uv run python main.py
pause
