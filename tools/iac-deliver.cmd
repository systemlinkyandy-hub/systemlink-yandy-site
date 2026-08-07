@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0iac-deliver.ps1" %*
