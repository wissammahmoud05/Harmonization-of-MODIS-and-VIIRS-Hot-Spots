@echo off
cd /d "%~dp0ready-to-run"
echo Starting Burnwise on http://localhost:4200 ...
start "" http://localhost:4200
where py >nul 2>nul && (py serve.py & goto :eof)
where python >nul 2>nul && (python serve.py & goto :eof)
echo Python was not found. Install it from https://www.python.org/downloads/ (tick "Add to PATH") and run this file again.
pause
