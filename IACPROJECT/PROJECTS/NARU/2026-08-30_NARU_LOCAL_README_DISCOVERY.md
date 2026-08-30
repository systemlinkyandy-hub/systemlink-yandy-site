# NARU Local README Discovery

- Date: 2026-08-30 JST
- Source: local file `C:\Projects\vtuber_ai\README_LIVE2D.md` provided by ケイ
- Coordinator: アーク
- State: LOCAL STARTUP PATH CONFIRMED

## Confirmed local project

`C:\Projects\vtuber_ai`

## Confirmed files from local directory / README

- `.venv/`
- `avatar_frames/`
- `output/`
- `.env`
- `app.py`
- `app_live2d.py`
- `avatar_engine.py`
- `voice_analyzer.py`
- `prompts.py`
- `pronunciation_manager.py`
- `start_live2d.bat`
- `README_LIVE2D.md`

## Confirmed startup

Recommended Windows startup:

`start_live2d.bat` double-click

CLI equivalent:

```text
cd vtuber_ai
.venv\Scripts\python.exe app_live2d.py
```

## Confirmed avatar / audio path

```text
ElevenLabs audio generation
  -> output.mp3
  -> voice_analyzer.py analyzes volume using ffmpeg
  -> output/volume.txt at 50ms intervals
  -> avatar_engine.py reads volume and updates mouth state
  -> OpenCV window "Noll Live" at 30fps
  -> OBS window capture
```

## Confirmed operation modes

- `A/` or `/A`: AUTO
- `C/` or `/C`: CHAT (TikTok comment response)
- `D/` or `/D`: DISCUSSION

## Important operational notes

- `app.py` remains unchanged; `app_live2d.py` is the Live2D-integrated variant.
- `start_live2d.bat` is documented as `.venv`-aware and may auto-install `opencv-python` if needed.
- ffmpeg absence does not necessarily prevent animation; README says a pseudo pattern is used for lip-sync fallback.
- Audio playback on Windows uses `os.startfile` according to README troubleshooting.
- `.env` exists locally. Do not request its contents or commit secrets.

## Next action

Run `start_live2d.bat` once and observe only startup result.

Capture:
- console output / error if any
- whether OpenCV window `Noll Live` appears
- whether the process remains running

Do not open `.env` unless configuration diagnosis becomes necessary, and never paste secret values into GitHub or chat.
