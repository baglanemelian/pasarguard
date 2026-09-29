@echo off
echo ==============================================
echo   PasarGuard Frontend Dev Server (Port 5173)...
echo ==============================================
cd /d %~dp0dashboard
bun run dev
pause
