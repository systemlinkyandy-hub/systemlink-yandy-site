@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -STA -File "%~dp0iac-chat-ui.ps1" %*
