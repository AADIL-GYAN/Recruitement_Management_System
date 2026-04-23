@echo off
echo Installing Python dependencies...
python -m pip install -r backend_python/requirements.txt

echo.
echo Starting Python Backend Server...
start "RMS Backend" python backend_python/app.py

echo.
echo Backend started!
echo Please open "frontend/login.html" in your browser.
pause
