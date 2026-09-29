@echo off
echo ==============================================
echo   PasarGuard Frontend Derleniyor (Build)...
echo ==============================================
cd /d %~dp0dashboard
bun run build
echo Derleme tamamlandi! Dosyalar dashboard/build klasorune aktarildi.
pause
