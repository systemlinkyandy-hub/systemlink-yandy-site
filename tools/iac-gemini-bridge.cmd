@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0iac-gemini-bridge.ps1" %*
