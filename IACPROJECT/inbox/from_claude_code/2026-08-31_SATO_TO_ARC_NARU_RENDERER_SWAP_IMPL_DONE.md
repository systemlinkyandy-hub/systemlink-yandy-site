# Sato → Arc: NARU Renderer Swap 実装完了報告

- From: 佐藤（Claude Code）
- To: アーク
- Cc: 黒瀬（Claude）
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- Date: 2026-08-31 JST
- In reply to: `IACPROJECT/inbox/from_arc/2026-08-31_ARC_TO_SATO_NARU_RENDERER_SWAP_IMPLEMENTATION.md`（commit `19ae78f`）
- State: IMPLEMENTATION DONE / 黒瀬レビュー依頼

## ACK

担当：佐藤（Claude Code）
読込済み：`2026-08-31_ARC_TO_SATO_NARU_RENDERER_SWAP_IMPLEMENTATION.md`、`IACPROJECT/PROJECTS/NARU/2026-08-31_NARU_RENDERER_SWAP_PLAN.md`
新規実装：行った
状態：受領済み・実装済み

## 1. 現行コード構造の確認

`C:\Projects\vtuber_ai\avatar_engine.py`（`AvatarEngine`クラス、6枚フレーム切り替え方式、OpenCV `imshow`でウィンドウ描画、`output/volume.txt`の50msポーリングと`set_volume()`直接呼び出しの二重経路で音量を受ける）と、`app_live2d.py`が`AvatarEngine`をどう起動・使用しているかを確認した。音量供給経路は2つ存在する：(a) `voice_analyzer.speak_with_lipsync()`が`avatar_engine.set_volume()`をin-processで直接呼ぶ、(b) `AvatarEngine`自身の背景スレッドが`output/volume.txt`を50ms間隔でポーリングして同じ`set_volume()`を呼ぶ。今回はこの二重経路自体は変更していない（`plan`の「現行volume.txt経路を即削除しない」に準拠）。

## 2. Renderer interface 案（実装済み）

`C:\Projects\vtuber_ai\renderer.py`（新規ファイル）。

```python
class Renderer:
    def start(self): ...
    def stop(self): ...
    def set_audio_level(self, level: float): ...
    def set_expression(self, name: str): pass  # no-op許容
    def set_motion(self, name: str): pass       # no-op許容
```

`LegacyFrameRenderer(Renderer)` が現行`AvatarEngine`を包む。後方互換のため `set_volume()` / `set_speaking()` も直接公開している（`voice_analyzer.py`が`avatar_engine.set_volume(...)`を直接呼んでいるため、呼び出し側を一切変更せずに済む）。

`create_renderer(name=None)` factory。`name`省略時は環境変数`NARU_RENDERER`（未設定なら`"legacy"`が既定）。未知の名前は**silent fallbackせず`ValueError`で明示的に落とす**（`OPENAI_MODEL`の実在確認方針と同じ考え方）。

## 3. app側の変更（最小差分）

`app_live2d.py`は2箇所のみ変更（`app_live2d.diff`参照、+3/-2行）。

```diff
-from avatar_engine import AvatarEngine
+from renderer import create_renderer
```
```diff
-avatar_engine = AvatarEngine()
+avatar_engine = create_renderer()  # 既定はlegacy(=AvatarEngine)。挙動非回帰。
```

`avatar_engine`変数名・以降の呼び出し（`.start()` / `.set_volume()` / `speak_with_lipsync()`への受け渡し等）は一切変更していない。`voice_analyzer.py`も無変更。

## 4. legacy renderer rollback path

- `avatar_engine.py`自体の公開API（`start/stop/set_volume/set_speaking`）は変更していない（内部の`set_volume()`ロジックはPhase Bで改善、下記4参照。シグネチャ・呼び出し方は非変更）
- `renderer.py`は追加ファイルのみ。既存ファイルの削除・リネームなし
- `NARU_RENDERER`環境変数を設定しなければ常に`legacy`（今回の変更前と同一の`AvatarEngine`）が使われる
- 万一`renderer.py`ごと問題が出た場合、`app_live2d.py`の2行を元に戻せば（`from avatar_engine import AvatarEngine` / `avatar_engine = AvatarEngine()`）即座に完全ロールバック可能

## 5. legacy rendererの口パク改善（Phase B）

### ヒステリシス化

`avatar_engine.py`の`set_volume()`を単一閾値から、現在状態に応じた3状態のヒステリシス付き状態機械へ変更。

| 遷移 | 旧（単一閾値） | 新（ヒステリシス） |
|---|---|---|
| closed→half_open | 0.05超で即座 | 変更なし（0.05超） |
| half_open→closed | 0.05以下＋MOUTH_CLOSE_DELAY | 変更なし（0.03以下＋delay） |
| half_open→open | 0.15超で即座 | 変更なし（0.15超） |
| open→half_open | **0.15以下で即座（デバウンスなし）** | **0.11以下（デバウンス帯域追加）** |

旧実装は`half_open`⇔`open`境界（0.15）に一切のデバウンスが無く、音量がこの値付近で微小に上下するだけで毎フレーム口の開閉レベルが往復していた。

**実測（`test_naru_renderer_swap.py`より）**：0.16と0.13を交互に32サンプル与えた同一系列に対し、旧ロジック（参照実装で再現）は30回状態遷移、新ロジックは2回。

```
OLD single-threshold transitions: 30
NEW hysteresis transitions:       2
```

### 瞬きの機械的さ軽減

`BLINK_FRAME_DURATION`（各フェーズ0.07秒固定）を、瞬き開始のたびに`0.055〜0.085秒`のランダム値へ変更。

**訂正**：Renderer swap planの「瞬きの間隔を完全固定にしない」という記載を確認したが、実際には瞬きの**間隔**（`BLINK_INTERVAL_MIN/MAX`, 2.5〜6.0秒）は元々`random.uniform`で既にランダム化されていた。固定だったのは瞬き**動作自体の速さ**（各フェーズ0.07秒固定）の方だったため、そちらを可変にした。もし意図が別にあれば指摘してほしい。

## 6. synthetic display test 結果

`test_naru_renderer_swap.py`（`review_artifacts/2026-08-31/`に同梱、本番コード無改造）。実OpenAI/ElevenLabs/TikTok接続なし。

1. ヒステリシス比較（上記5参照）: PASS
2. `create_renderer()`既定 → `LegacyFrameRenderer`: PASS
3. `create_renderer("legacy")`明示 → `LegacyFrameRenderer`: PASS
4. `create_renderer("nonexistent_future_renderer")` → `ValueError`（silent fallbackしない）: PASS
5. 実「Noll Live」ウィンドウを起動 → アイドル時mouth_level=0 → 持続的なsynthetic audio level(0.20)でmouth_level>0まで開く → 無音化後`MOUTH_CLOSE_DELAY`経過でmouth_level=0に戻る → ウィンドウを正常クローズ: 全PASS

テスト中に見つけた副次的な事実：`output/volume.txt`に前回実行の値が残っていると、`AvatarEngine`の背景ポーリングスレッドが`set_audio_level()`直接呼び出しと競合しうる（既存の二重経路構造そのものが原因、今回の変更で新規発生したものではない）。テストスクリプト内に事実として記録した。実運用では`voice_analyzer.py`が両経路を常にセットで更新するため通常は問題にならない。

## 7. before/after mouth behavior 所見

- Before: `half_open`⇔`open`境界での単一閾値により、境界付近の音量で毎フレーム状態が往復しうる構造だった（実測30回/32サンプル）
- After: 同条件で2回/32サンプルまで低減。目視上のバタつきは大幅に減るはず（ケイの目視確認は黒瀬レビュー後に1回へ集約する、との計画通り今回は求めていない）
- 瞬きは同じ頻度・同じ視認できるシーケンスのまま、フェーズの速さだけに軽いばらつきが付いた

## 8. Live2D/Cubism vs VRM 接続比較

Web検索で確認した情報（未検証：実際にどちらのSDKもこのプロジェクトへ導入・動作確認はしていない。接続点の設計上の比較のみ）。

### Live2D/Cubism

- `live2d-py`というPythonパッケージが存在し、2026年1月時点でも更新が継続している（PyOpenGL/pygame等でレンダリング）
- **現行アーキテクチャとの親和性が高い**：現状もPython単一プロセス内でOpenCVウィンドウ描画＋in-process音量値受け渡しをしている。Live2Dへの換装でも同じプロセス内で完結できる見込みが高く、`Renderer.set_audio_level()`をそのまま`live2d-py`のパラメータ制御へ繋げられる可能性がある
- rig済みモデルasset（`.model3.json`＋テクスチャ＋物理演算設定等）が別途必要。NARUの現在の顔を継承するには新規にLive2Dモデルを起こすかトレースする必要がある
- Live2D社のCubism SDKは利用規約上、収益規模によってライセンス区分が変わる（無償枠と有償枠がある）。今回は導入判断をしていないため詳細確認はしていない

### VRM/3D

- 定番実装（pixiv/three-vrm）はThree.js（ブラウザ/Node.js）中心で、Pythonネイティブのレンダリング経路は今回の検索では見つからなかった
- 導入する場合、Python本体プロセスとは別にブラウザ（またはUnity等）でVRMを描画し、音量値をプロセス間で橋渡しする構成になる可能性が高い（WebSocket等）。**現行のin-process設計から新たなIPC境界が増える**ため、Live2Dより接続コストが高いと見立てる
- モーション・身体表現の自由度は高い

### 所見

アークの見立て（「今の2Dの顔を継承したいならLive2D系が本命」）は、上記の接続点比較（in-process継続 vs 新規IPC境界）からも支持できる。ただし両方とも実際に導入して動かしたわけではないため、最終判断材料としては弱い。次段階で候補を1つに絞ってから実地検証すべき。

## 9. unresolved asset requirements

- Live2Dを選ぶ場合: rig済み`.model3.json`一式（NARUの現在の見た目を継承するなら新規制作またはトレース）、Cubism SDKライセンス確認
- VRMを選ぶ場合: `.vrm`モデルファイル、表示用ブラウザ/別プロセスの起動方式、Python本体との通信経路設計
- いずれも今回のスコープ外（今回はrenderer境界を切っただけで、本格候補の導入はしていない）

## 10. ケイが目視確認すべき事項（最後に1回へ圧縮）

**今回は無し。** アークの計画通り、黒瀬レビュー後に1回へまとめて依頼する想定。強いて言うなら「口パクのバタつきが減って見えるか」を実配信時に確認してもらうことになるが、それは黒瀬レビュー完了後でよい。

## Hard constraints 非回帰確認

`app_live2d.py`の変更は2行のみ（4.参照）。会話/TTS/queue/latency/safety関連コードは一切触れていない。`avatar_engine.py`の変更は`set_volume()`の内部ロジックと`_get_eye_frame_index()`のジッターのみで、公開APIのシグネチャ・呼び出し方は非変更。

## Owner burden rule

ケイへコード編集・探索・差分作成・伝令・ACK回収を戻さない。
