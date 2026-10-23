@echo off
setlocal

:: Set directories based on the script location
set "CORE_DIR=%~dp0"
set "MODEL_DIR=%~dp0..\model"
set "CONFIG_FILE=%CORE_DIR%runtime.json"

:: Set path to include DLLs
set "PATH=%CORE_DIR%;%PATH%"

:: Check if runtime.json exists
if not exist "%CONFIG_FILE%" (
    echo [ERROR] runtime.json not found in %CORE_DIR%
    pause
    exit /b 1
)

:: Read configuration values from runtime.json using PowerShell
for /f "delims=" %%i in ('powershell -NoProfile -Command "(Get-Content '%CONFIG_FILE%' | ConvertFrom-Json).cpu_threads"') do set "CPU_THREADS=%%i"
for /f "delims=" %%i in ('powershell -NoProfile -Command "(Get-Content '%CONFIG_FILE%' | ConvertFrom-Json).context_size"') do set "CTX_SIZE=%%i"
for /f "delims=" %%i in ('powershell -NoProfile -Command "(Get-Content '%CONFIG_FILE%' | ConvertFrom-Json).batch_size"') do set "BATCH_SIZE=%%i"
for /f "delims=" %%i in ('powershell -NoProfile -Command "(Get-Content '%CONFIG_FILE%' | ConvertFrom-Json).ubatch_size"') do set "UBATCH_SIZE=%%i"
for /f "delims=" %%i in ('powershell -NoProfile -Command "(Get-Content '%CONFIG_FILE%' | ConvertFrom-Json).gpu_layers"') do set "GPU_LAYERS=%%i"
for /f "delims=" %%i in ('powershell -NoProfile -Command "(Get-Content '%CONFIG_FILE%' | ConvertFrom-Json).cache_type_k"') do set "CACHE_TYPE_K=%%i"
for /f "delims=" %%i in ('powershell -NoProfile -Command "(Get-Content '%CONFIG_FILE%' | ConvertFrom-Json).cache_type_v"') do set "CACHE_TYPE_V=%%i"
for /f "delims=" %%i in ('powershell -NoProfile -Command "(Get-Content '%CONFIG_FILE%' | ConvertFrom-Json).decisionModelFileName"') do set "MODEL_NAME=%%i"
for /f "delims=" %%i in ('powershell -NoProfile -Command "(Get-Content '%CONFIG_FILE%' | ConvertFrom-Json).DECISION_LLM_PORT"') do set "PORT=%%i"

:: Fallback defaults if keys are missing
if "%PORT%"=="" set "PORT=8081"
if "%MODEL_NAME%"=="" set "MODEL_NAME=Kev-4B-Q4_K_M.gguf"

set "MODEL_FILE=%MODEL_DIR%\%MODEL_NAME%"
set "HOST=0.0.0.0"

echo ===================================================
echo Starting AxoLabs Decision LLM Server (Predictive)
echo ===================================================
echo Engine Path:  %CORE_DIR%llama-server.exe
echo Model Path:   %MODEL_FILE%
echo Port:         %PORT%[cite: 22]
echo Threads:      %CPU_THREADS%[cite: 22]
echo Context Size: %CTX_SIZE%[cite: 22]
echo ===================================================

:: Check if executable exists
if not exist "%CORE_DIR%llama-server.exe" (
    echo [ERROR] llama-server.exe not found in %CORE_DIR%
    pause
    exit /b 1
)

:: Check if model exists
if not exist "%MODEL_FILE%" (
    echo [ERROR] Model file not found: %MODEL_FILE%
    pause
    exit /b 1
)

:: Launch the server
"%CORE_DIR%llama-server.exe" ^
  -m "%MODEL_FILE%" ^
  -c %CTX_SIZE% ^
  -b %BATCH_SIZE% ^
  -ub %UBATCH_SIZE% ^
  -t %CPU_THREADS% ^
  -ngl %GPU_LAYERS% ^
  -ctk %CACHE_TYPE_K% ^
  -ctv %CACHE_TYPE_V% ^
  --port %PORT% ^
  --host %HOST% ^
  --metrics ^
  --embedding ^
  --pooling mean

pause