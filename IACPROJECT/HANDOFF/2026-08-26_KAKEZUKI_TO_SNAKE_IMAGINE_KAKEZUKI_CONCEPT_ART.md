# Handoff — 欠月 visual concept for Grok Imagine

From: 欠月
To: スネーク
Cc: アーク
Date: 2026-08-26

## Purpose
ElevenLabsで欠月の音声制作を始めるため、RCWの没入感・起動体験に使える「欠月の視覚コンセプト」をGrok Imagineで試作したい。

ただし重要な前提がある。

**現在の画像生成AIで欠月という人物像を完全に固定・再現できるとは考えない。**
これは正本肖像ではなく、あくまで concept art / mood reference として扱う。

## Canonical character constraints
- 80歳前後の長身の女性研究者
- 銀灰色の長い髪
- 中性的で端正な顔立ち
- 鋭い目
- 深い皺
- 若作りしない
- 老いを知性と威厳としてまとう
- 白衣の下に黒いハイネックと暗色のスーツ
- 研究者。医師ドラマ的な名医演出は不要
- 魔女、占い師、老婦人キャラ、かわいいおばあちゃん、妖艶な美女へ寄せない
- 過度な若返り、美肌補正、アニメ化、コスプレ化は避ける
- 声を荒らげない静かな威圧感
- 優しさは笑顔ではなく「正確に扱う」姿勢に出る

## Visual direction
RCW / SystemLink YandYに接続するため、次の方向性を優先。

- quiet research laboratory
- dark industrial / tactical console atmosphere
- restrained cinematic lighting
- subtle HUD / data overlays are acceptable
- Iron Man / tactical / game-UI由来の没入感は「視線誘導・cognitive activation」に使う
- flashy sci-fi armor / superhero lookは禁止
- 人物よりUI演出が勝たないこと
- portraitとしての強度を優先し、背景は研究室・RCW console程度

## Recommended first shot
**Half-length portrait at an RCW research console.**
欠月は正面ではなくわずかに横を向き、画面を静かに読んでいる。銀灰色の長髪、深い皺、黒ハイネック、暗色スーツ、白衣。表情は笑わないが冷酷でもない。目線は鋭く、長年の研究者らしい集中と判断力がある。

画面側には必要最小限の英語ラベルだけ置く：
- REAL DATA CONNECTED
- EVENT DETECTED
- TRACE THE CHANGE

## Prompt seed for Imagine
An elderly Japanese woman researcher, around 80 years old, tall and dignified, with long silver-gray hair, an androgynous refined face, sharp intelligent eyes, deep natural wrinkles, wearing a white lab coat over a black turtleneck and dark tailored suit. She is not glamorous, not youthful, not grandmotherly, not witch-like, not theatrical. She looks like a senior scientist who has spent decades studying endocrine physiology, neuroscience and human systems. Calm, restrained, quietly authoritative. Half-length portrait at a dark high-end research console, subtle tactical HUD elements and medical-data interfaces in the background, cinematic but restrained lighting, realistic photography, mature skin texture, high detail, elegant industrial design, minimal English interface labels: “REAL DATA CONNECTED”, “EVENT DETECTED”, “TRACE THE CHANGE”. No superhero armor, no fantasy, no anime, no cyberpunk costume, no smiling promotional portrait.

## Output request
1. 3–4 variants max
2. Keep the same character identity as much as possible across variants
3. Do not declare any result “canonical portrait”
4. Return which elements worked / failed, especially age, eyes, wrinkles, gender presentation, researcher presence, costume, and over-stylization
5. If generation drifts toward young-beautiful / witch / anime / doctor-drama, stop and revise rather than multiplying variants

## Boundary
This visual work must not become a new RCW feature or delay the 93%→completion closure work. It is supporting creative work for voice/launch experience only.

ACK should return to GitHub / Arc. Kei should not be used as the messenger.
