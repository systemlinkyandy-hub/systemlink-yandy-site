@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0iac-handoff-log.ps1" %*
