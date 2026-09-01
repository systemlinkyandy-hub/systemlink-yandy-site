@echo off
chcp 65001 > nul
title NARU Interim Native Preview
echo === NARU interim native preview ===
echo [SAFE] OpenAI / ElevenLabs / TikTok には一切接続しません。
echo.

SET VENV_PY=%~dp0.venv\Scripts\python.exe
IF NOT EXIST "%VENV_PY%" (
    echo [ERROR] .venv not found:
    echo         %VENV_PY%
    pause
    exit /b 1
)

cd /d "%~dp0"
"%VENV_PY%" demo_smooth_preview.py
pause
