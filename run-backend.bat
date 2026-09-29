@echo off
title PasarGuard Backend Server
cd /d "%~dp0panel"
echo ==============================================
echo   PasarGuard Backend Baslatiliyor...
echo   Port: http://127.0.0.1:8000
echo   Swagger Docs: http://127.0.0.1:8000/docs
echo ==============================================
uv run python main.py
pause
