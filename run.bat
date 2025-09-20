echo off

cls
odin version

set OUT_DIR=build\debug\windows\x86
set APPLE_NAME=zombie

echo run test
odin test %APPLE_NAME%
IF %ERRORLEVEL% NEQ 0 exit /b 1

echo create debug build directory if not exist
if exist %OUT_DIR% rmdir /s /q %OUT_DIR%
mkdir %OUT_DIR%
IF %ERRORLEVEL% NEQ 0 exit /b 1

echo create debug build
odin build %APPLE_NAME% -out:%OUT_DIR%\%APPLE_NAME%_debug.exe -strict-style -vet -debug
IF %ERRORLEVEL% NEQ 0 exit /b 1
echo Debug build created in %OUT_DIR%

echo copy assets to output directory
xcopy /y /e /i assets %OUT_DIR%\assets > nul
IF %ERRORLEVEL% NEQ 0 exit /b 1

echo Copy external DLLs to output directory
xcopy /y D:\DevTools\Odin\vendor\sdl3\sdl3.dll %OUT_DIR% > nul
IF %ERRORLEVEL% NEQ 0 exit /b 1
xcopy /y D:\DevTools\Odin\vendor\sdl3\ttf\sdl3_ttf.dll %OUT_DIR% > nul
IF %ERRORLEVEL% NEQ 0 exit /b 1
xcopy /y D:\DevTools\Odin\vendor\sdl3\image\sdl3_image.dll %OUT_DIR% > nul
IF %ERRORLEVEL% NEQ 0 exit /b 1

echo start debug build
%OUT_DIR%\%APPLE_NAME%_debug.exe
echo.