@echo off
echo ==============================================
echo   PasarGuard Tum Servisleri Baslatiliyor...
echo ==============================================
start "PasarGuard Backend" cmd /k "cd /d %~dp0 && uv run python main.py"
timeout /t 3 /nobreak >nul
start "PasarGuard Frontend Dev" cmd /k "cd /d %~dp0dashboard && bun run dev"
echo Servisler baslatildi!
echo Tarayicinizda su adresleri acabilirsiniz:
echo - Gelistirme Arayuzu (Hot Reload): http://localhost:5173
echo - Backend ve API Dokumantasyonu: http://127.0.0.1:8000/docs
echo - Standart Panel: http://127.0.0.1:8000/dashboard/
pause
