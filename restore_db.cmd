@echo off
REM Database Restore Script
REM Restores the most recent SQLite database backup

echo Database Restore Script
echo =====================

REM Get version from ddon.version file
SET /p VERSION=<ddon.version
SET TARGET_PATH=.\publish\win-x64-%VERSION%\Server\Files\Database\db.sqlite
SET BACKUP_DIR=.\backup

REM Check if backup directory exists
if not exist %BACKUP_DIR% (
    echo ERROR: Backup directory does not exist: %BACKUP_DIR%
    echo No backups found to restore.
    pause
    exit /b 1
)

REM Check if there are any backup files
dir /b %BACKUP_DIR%\db.sqlite.backup.* >nul 2>&1
if errorlevel 1 (
    echo ERROR: No backup files found in %BACKUP_DIR%
    echo Looking for files matching pattern: db.sqlite.backup.*
    pause
    exit /b 1
)

REM Find the most recent backup file (sorted by name, which includes timestamp)
for /f "delims=" %%i in ('dir /b /o:-n %BACKUP_DIR%\db.sqlite.backup.* 2^>nul') do (
    set LATEST_BACKUP=%%i
    goto :found
)

:found
if "%LATEST_BACKUP%"=="" (
    echo ERROR: Could not determine the latest backup file.
    pause
    exit /b 1
)

echo Found latest backup: %LATEST_BACKUP%
echo Target location: %TARGET_PATH%

REM Check if target directory exists, create if needed
if not exist ".\publish\win-x64-%VERSION%\Server\Files\Database\" (
    echo Creating target directory structure...
    mkdir ".\publish\win-x64-%VERSION%\Server\Files\Database\"
)

REM Backup current database if it exists
if exist %TARGET_PATH% (
    echo Current database exists. Creating safety backup...
    copy %TARGET_PATH% %BACKUP_DIR%\db.sqlite.pre-restore.%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%%time:~6,2%
    echo Safety backup created.
)

REM Restore the backup
echo Restoring database from backup...
copy %BACKUP_DIR%\%LATEST_BACKUP% %TARGET_PATH%

if errorlevel 1 (
    echo ERROR: Failed to restore database backup.
    pause
    exit /b 1
) else (
    echo SUCCESS: Database restored successfully!
    echo Restored from: %BACKUP_DIR%\%LATEST_BACKUP%
    echo Restored to: %TARGET_PATH%
)

echo.
echo Restore completed.
pause
