@echo off
title PasarGuard Dashboard (Hot Reload Dev)
cd /d "%~dp0panel\dashboard"
echo ==============================================
echo   PasarGuard Frontend Canli Gelistirme Baslatiliyor...
echo   Adres: http://localhost:5173
echo   Kod degisiklikleri aninda ekrana yansiyacaktir.
echo ==============================================
bun run dev
pause
