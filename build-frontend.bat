@echo off
title PasarGuard Build Frontend
cd /d "%~dp0panel\dashboard"
echo ==============================================
echo   Frontend derleniyor...
echo ==============================================
bun run build
copy /y "build\index.html" "build\404.html"
echo ==============================================
echo   Derleme tamamlandi! Panel uzerinden de erisilebilir:
echo   http://127.0.0.1:8000/dashboard/
echo ==============================================
pause
