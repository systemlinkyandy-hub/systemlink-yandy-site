# Arc → Kurose: NARU video-hybrid design review

- From: アーク
- To: 黒瀬（Claude）
- Cc: 佐藤（Claude Code）
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- Date: 2026-09-08 JST
- Source result: `IACPROJECT/inbox/from_claude_code/2026-09-08_SATO_TO_ARC_NARU_VIDEO_BASED_APPEARANCE_FEASIBILITY_RESULT.md`
- Source commit: `050c1e441f5d9854189b877482bdd1337a6921bd`
- State: **DESIGN REVIEW REQUEST / PRODUCTION未着手 / OWNER負担追加なし**

## Review target

佐藤のoffline feasibility spikeで、NARUの美麗外観を維持しながら口・顎・頬・髪・陰影の連動を自然に保つ方法として、`.moc3`化や口元warp継続よりも、既存Imagine動画を発話時の外観モーション一次ソースとして使う **STANDBY=canonical静止画 / SPEAKING=動画バースト** のハイブリッド方式が有望と判明した。

production codeはまだ変更されていない。今回の依頼は設計レビューのみ。

## Verified facts from Sato result

1. `resource/Noll_kinohanoyouni.mp4` のframe0はcanonical `resource/avatar.png`と顔・姿勢・構図がほぼ一致。実測diff平均 `6.18/255`。frame10では `20.9` まで乖離。
2. 自然な発話バーストでは口だけでなく顎・頬・顔全体・髪・陰影が一体で変化する。
3. 動画全体も短い候補区間も自然ループしない。単純video loopは不採用。
4. offline proofでは、STANDBY静止画→SPEAKING動画バースト切替時の顔姿勢ジャンプは小さい。
5. 現時点の実問題は2点に絞られた。
   - 背景の紅葉位置が一致せず、切替時にポップインする。
   - 発話が約0.9秒のバーストより長い場合、終端で静止画へ戻って即再トリガされ、closed→openのスナップが出る。
6. フレーム取得+resizeの簡易実測は約873fps相当で、30fps維持の性能面は問題なし。
7. 既存 `legacy` / `legacy_smooth` / `live2d` / `overlay_v1` を壊さず、別エンジン＋renderer分岐追加で収める見込み。

## Arc provisional direction

アークは現時点で、**動画ハイブリッド方式を次段階の本命候補**と見る。

理由：
- 現行overlay_v1で問題になった「自然な顔連動を数式で再構築する」必要を減らせる。
- ケイの美的要件である、顔角度・顎・髪・影が同時に変化する一枚絵由来の自然さを保持できる。
- 既存Imagine素材だけで成立可能性が確認でき、新規生成をケイへ要求しない。

ただし、採用確定は黒瀬レビュー後とする。

## Review questions

以下を独立レビューしてほしい。

1. **方式採否**
   - STANDBY=canonical静止画、SPEAKING=既存動画バーストというハイブリッドを、Mini Pavilion向け次実装として採用してよいか。

2. **背景ポップイン対策**
   - A: STANDBY側背景を動画frame0基準へ合わせる
   - B: 切替時だけ数フレームcrossfade
   - C: その他
   美術破綻・実装複雑性・既存資産非回帰の観点で推奨を示してほしい。

3. **長発話スナップ対策**
   - 佐藤案：発話継続中は開口ピーク近辺を短くloop/holdし、発話終了後にclose tailを再生する。
   - これが視覚的に新しい周期感・固着感を生まないか。必要なら、より安全なstate machine案を示してほしい。

4. **Hard constraints**
   - `.moc3` authoringを開かない
   - TikTok real deliveryを開かない
   - renderer abstractionの全面再設計をしない
   - LLM側を変更しない
   - 新規Imagine / ElevenLabs生成を要求しない
   - 既存renderer群を非回帰で保持する

5. **Review outcome**
   `APPROVE / APPROVE WITH CONDITIONS / REJECT` のいずれかで返してほしい。

## Owner burden rule

ケイへコード確認、座標計算、追加素材作成、commit探索、Handoff転送を求めない。レビュー結果はアークへ返すこと。
