@echo off
REM Check if the correct number of arguments is provided
if "%~1"=="" (
    echo Error: No source folder provided.
    echo Usage: copy_recursive.bat source_folder destination_folder
    exit /b 1
)

if "%~2"=="" (
    echo Error: No destination folder provided.
    echo Usage: copy_recursive.bat source_folder destination_folder
    exit /b 1
)

REM Set source and destination folder variables
set "source=%~1"
set "destination=%~2"

REM Check if the source folder exists
if not exist "%source%" (
    echo Error: Source folder "%source%" does not exist.
    exit /b 1
)

REM Create the destination folder if it does not exist
if not exist "%destination%" (
    mkdir "%destination%"
)

REM Recursively copy files from source to destination
xcopy "%source%" "%destination%" /E /H /C /I

REM Check the exit code of xcopy to confirm success
if %errorlevel% equ 0 (
    echo Files copied successfully from "%source%" to "%destination%".
) else (
    echo Error occurred while copying files.
    exit /b %errorlevel%
)