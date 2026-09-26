@echo off
rem tests\run.bat
rem Thin Windows wrapper around tests\run_all.lua. Works from any starting
rem directory: it switches to the repo root (the parent of this script's own
rem folder), runs the suite, then returns to wherever it was called from.
setlocal
set "GYROPATH_TESTS_DIR=%~dp0"
set "GYROPATH_REPO_ROOT=%GYROPATH_TESTS_DIR%.."
set "GYROPATH_ORIG_DIR=%CD%"

cd /d "%GYROPATH_REPO_ROOT%"
lua tests\run_all.lua %*
set "GYROPATH_EXIT_CODE=%ERRORLEVEL%"

cd /d "%GYROPATH_ORIG_DIR%"
endlocal & exit /b %GYROPATH_EXIT_CODE%
