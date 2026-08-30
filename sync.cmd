@echo off
setlocal EnableExtensions EnableDelayedExpansion

title Decompile-stuff GitHub Sync

set "SOURCE=C:\Users\irakl\Downloads\Decompile-stuff"
set "REPO_URL=https://github.com/Irakli17/Decompile-stuff.git"
set "REPO=C:\Users\irakl\Downloads\Decompile-stuff-git"

cls

echo ============================================================
echo                 DECOMPILE-STUFF GITHUB SYNC
echo ============================================================
echo.

echo [1/6] Checking source folder...
echo.

if not exist "%SOURCE%\" (
    echo ERROR: This folder does not exist:
    echo.
    echo %SOURCE%
    echo.
    echo Checking Downloads for matching folders...
    echo.

    dir /b /ad "%USERPROFILE%\Downloads"

    echo.
    echo The exact source path must exist before syncing.
    echo.
    goto FAIL
)

echo Source folder found:
echo %SOURCE%
echo.

echo [2/6] Checking Git...

where.exe git >nul 2>&1

if errorlevel 1 (
    echo.
    echo ERROR: Git is not installed.
    echo.
    goto FAIL
)

git --version
echo.

echo [3/6] Preparing Git repository...

if not exist "%REPO%\.git\" (

    if exist "%REPO%\" (
        echo Local folder exists but is not a Git repository.
        echo Removing it...
        rmdir /s /q "%REPO%"
    )

    echo Cloning repository...
    echo.

    git clone "%REPO_URL%" "%REPO%"

    if errorlevel 1 (
        echo.
        echo ERROR: Could not clone repository.
        echo.
        goto FAIL
    )

) else (

    echo Existing Git repository found.

)

cd /d "%REPO%"

if errorlevel 1 (
    echo.
    echo ERROR: Could not enter:
    echo %REPO%
    echo.
    goto FAIL
)

echo.

echo [4/6] Updating repository...

git fetch origin

if errorlevel 1 (
    echo.
    echo ERROR: git fetch failed.
    echo.
    goto FAIL
)

git checkout main >nul 2>&1

if errorlevel 1 (
    git checkout -B main
)

if errorlevel 1 (
    echo.
    echo ERROR: Could not switch to main.
    echo.
    goto FAIL
)

echo.

echo [5/6] Synchronizing source folder...
echo.
echo SOURCE:
echo %SOURCE%
echo.
echo DESTINATION:
echo %REPO%
echo.

robocopy "%SOURCE%" "%REPO%" /MIR /COPY:DAT /DCOPY:DAT /R:2 /W:2 /XJ /FFT /XD "%SOURCE%\.git" "%REPO%\.git"

set "ROBOCODE=%ERRORLEVEL%"

echo.

if %ROBOCODE% GEQ 8 (
    echo ERROR: Robocopy failed.
    echo Exit code: %ROBOCODE%
    echo.
    goto FAIL
)

echo Source folder synchronized.
echo.

echo [6/6] Committing and pushing...
echo.

git add -A

if errorlevel 1 (
    echo.
    echo ERROR: git add failed.
    echo.
    goto FAIL
)

git diff --cached --quiet

if errorlevel 1 (

    echo Changes detected.
    echo.

    git status --short

    echo.
    echo Creating commit...

    git commit -m "Sync Decompile-stuff folder"

    if errorlevel 1 (
        echo.
        echo ERROR: Commit failed.
        echo.
        goto FAIL
    )

    echo Commit created.

) else (

    echo No changes detected.

)

echo.
echo Pushing to GitHub...
echo.

git push -u origin main

if errorlevel 1 (
    echo.
    echo ERROR: Git push failed.
    echo.
    goto FAIL
)

echo.
echo ============================================================
echo                    SYNC COMPLETE
echo ============================================================
echo.
echo Source:
echo %SOURCE%
echo.
echo GitHub:
echo %REPO_URL%
echo.
echo Everything in the source folder is synchronized.
echo.
echo ============================================================
echo.

pause
exit /b 0

:FAIL

echo.
echo ============================================================
echo                       SYNC FAILED
echo ============================================================
echo.
echo The script stopped so the error remains visible.
echo.
pause
exit /b 1