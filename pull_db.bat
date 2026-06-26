@echo off
echo ========================================
echo  Pull SQLite DB from Android Emulator
echo ========================================

set ADB=%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe
set PACKAGE=com.example.flutter_application_1
set DB_NAME=task_manager.db
set REMOTE_PATH=/data/data/%PACKAGE%/databases/%DB_NAME%
set LOCAL_PATH=%~dp0%DB_NAME%

echo [1/2] Pulling database from emulator...
"%ADB%" pull %REMOTE_PATH% "%LOCAL_PATH%"

if %errorlevel% == 0 (
    echo.
    echo [2/2] SUCCESS! File saved to:
    echo       %LOCAL_PATH%
    echo.
    echo  Open VS Code, right-click task_manager.db
    echo  chon "Open Database" de xem data.
) else (
    echo.
    echo  LOI: Khong the pull database.
    echo  Kiem tra lai:
    echo    1. Android emulator dang chay
    echo    2. App da duoc mo it nhat 1 lan
)

echo.
pause
