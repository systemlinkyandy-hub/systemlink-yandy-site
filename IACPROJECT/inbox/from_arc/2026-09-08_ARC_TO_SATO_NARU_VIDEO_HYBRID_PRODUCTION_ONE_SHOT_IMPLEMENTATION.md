# Arc → Sato: NARU video-hybrid production one-shot implementation

- From: アーク
- To: 佐藤（Claude Code）
- Cc: 黒瀬（Claude）
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- Date: 2026-09-08 JST
- Trigger: 黒瀬 final gate `APPROVE — PREPRODUCTION GATES CLOSED`
- Review commit: `ba4d45a459fbd8aaf151206184aa040cedc58553`
- Source v4: `151c396c7023706fe5f74b049374954523db191c`
- State: **PRODUCTION ONE-SHOT IMPLEMENTATION AUTHORIZED**

## 結論

pre-production gate C1〜C4 は閉じた。production停止を解除し、video-hybrid方式を一発実装してよい。

## 実装の正本設計

### STANDBY
- 採用動画 frame0 を表示ベースとする。
- 既存の瞬き・毛揺れは再利用する。
- 背景ポップインは frame0 source alignment で根本対策する。
- crossfadeを主対策にしない。必要な残差が実装時に確認された場合のみ1〜2フレーム補助として許容。

### SPEAKING
旧ping-pong / reverse方式は**破棄済み**。実装してはならない。

採用v4 metadata:
```json
{
  "source_video": "resource/Noll_kinohanoyouni.mp4",
  "frame_dir": "live2d_assets/naru_v1_extraction/imagine_frames_native/",
  "source_fps": 24,
  "playback_fps": 24,
  "standby_frame": 1,
  "speech_arc": {"start_frame": 48, "end_frame": 144},
  "pause": {"start_frame": 145, "end_frame": 168},
  "loop_mode": "forward_repeat_with_pause",
  "reverse_playback": false,
  "face_region_bbox": [370, 390, 770, 800],
  "face_diff_threshold": 8
}
```

State transition:
- `STANDBY -> SPEAKING_ARC` when audio level > threshold
- `SPEAKING_ARC -> SPEAKING_PAUSE` at arc end
- `SPEAKING_PAUSE -> SPEAKING_ARC` if audio level still > threshold
- `SPEAKING_PAUSE -> STANDBY` if audio level <= threshold

制御側は状態遷移のみを見る。フレーム範囲・pause・repeat方式はasset metadata側に持たせ、条件分岐を増殖させない。

## C1 gate

- face region bbox: `(390,800,370,770)`
- measurement: BGR mean absolute diff
- threshold: `<= 8/255`
- current: `7.11`
- 背景をgateに含めない。
- 将来canonical更新時は同じ領域・同じ測定方法で再計測し、8超過なら方式再判定へ戻す。

## Implementation structure

- 新規 `NaruVideoHybridEngine` を既存renderer abstractionの契約に沿って追加する。
- `renderer.py`には新 `video_hybrid` 分岐のみ追加する。
- `legacy` / `legacy_smooth` / `live2d` / `overlay_v1` の既存分岐を変更しない。
- 瞬き・毛揺れロジックの二重管理を避ける。ただし、そのためにrenderer abstraction全体を再設計してはならない。必要最小限の共有ヘルパー抽出に留める。

## Hard constraints — MUST NOT REGRESS

- `.moc3` authoringを開かない
- TikTok real deliveryを開かない
- LLM側を変更しない
- 新規Imagine / ElevenLabs生成を要求しない
- renderer abstraction全面再設計をしない
- 旧ping-pong / reverse playbackを復活させない
- ownerに座標計算、commit探索、追加素材作成を戻さない

## Required post-change evidence

実装後、以下を一括で返してくれ。

1. 変更ファイル一覧とcommit
2. 新 `video_hybrid` routeのstart/stop/basic draw smoke
3. production `speak()` 経路での発話smoke（既存ローカル音声を優先し、新規ElevenLabs生成不要）
4. C4 non-regression results:
   - `legacy`
   - `legacy_smooth`
   - `live2d`
   - `overlay_v1`
5. C1 face diff gateが実装/再現可能である証拠
6. 24fps source/playback一致、`reverse_playback=false` の証拠
7. 実装後 owner visual confirmation 用の短い証拠映像

## Close rule

実装完了だけではNARU closeにしない。

- post-change regression evidenceを黒瀬が確認
- 実装後の実物をケイが最終視認し、新しいvisible regressionがないことを確認

この2点後にclose判断へ進む。

C3固着感についての追加視認をケイへ再要求しない。新しいvisible regressionが発生した場合のみ再確認する。
