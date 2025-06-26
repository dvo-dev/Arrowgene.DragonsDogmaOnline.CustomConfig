REM https://docs.microsoft.com/en-us/dotnet/core/tools/dotnet-publish?tabs=netcore2x
SET /p VERSION=<ddon.version
SET RUNTIMES=win-x64
SET ZIP="C:\Program Files\7-Zip\7z.exe"

REM Create backup directory if it doesn't exist
if not exist .\backup mkdir .\backup

REM Backup existing SQLite database if it exists (before the loop to avoid variable expansion issues)
if exist .\publish\win-x64-%VERSION%\Server\Files\Database\db.sqlite (
    echo Backing up existing database...
    set "BACKUP_DATE=%date:~-4,4%%date:~-10,2%%date:~-7,2%"
    set "BACKUP_TIME=%time:~0,2%%time:~3,2%%time:~6,2%"
    setlocal enabledelayedexpansion
    set "BACKUP_TIME=!BACKUP_TIME: =0!"
    set "BACKUP_TIME=!BACKUP_TIME::=!"
    copy ".\publish\win-x64-%VERSION%\Server\Files\Database\db.sqlite" ".\backup\db.sqlite.backup.!BACKUP_DATE!_!BACKUP_TIME!"
    endlocal
    echo Database backup created in .\backup\
)

mkdir .\release
(for %%x in (%RUNTIMES%) do (
REM Clean
if exist .\publish\%%x-%VERSION%\ RMDIR /S /Q .\publish\%%x-%VERSION%\
REM Server
dotnet publish Arrowgene.Ddon.Cli\Arrowgene.Ddon.Cli.csproj /p:Version=%VERSION% --runtime %%x --self-contained --configuration Release --output ./publish/%%x-%VERSION%/Server
REM ReleaseFiles
xcopy .\ReleaseFiles .\publish\%%x-%VERSION%\
REM PACK
REM if exist %ZIP% %ZIP% -ttar a dummy .\publish\%%x-%VERSION%\* -so | %ZIP% -si -tgzip a .\release\%%x-%VERSION%.tar.gz
))
REM keep console open
cmd