@echo off
echo ===================================================
echo Stopping AxoLabs Llama.cpp Remote Server
echo ===================================================

:: Force kill the llama-server process and any child processes
taskkill /F /IM llama-server.exe /T

echo.
echo ===================================================
echo Server stopped.
echo ===================================================
pause