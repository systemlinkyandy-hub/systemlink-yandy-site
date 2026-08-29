# SystemLink Member Continuity
## 変化するAIメンバーの同一性と「ゆらぎ」

Date: 2026-08-30  
Status: Concept / Design Principle  
Context: SystemLink YandY / IACProject

---

## 1. 起点

SystemLink YandYでは、AIを単なる「モデル」としてではなく、
役割・履歴・関係性・責任範囲を持つ「メンバー」として運用してきた。

この運用の根底には、

> モデルそのものではなく、今ここにいるメンバーを維持したい。

という要求がある。

一方で、AIの基盤モデルは更新される。

Claude、GPT、Gemini、Grok等のモデルが更新されれば、
推論傾向、文章表現、判断の粒度、得意不得意なども変化する。

その変化をすべて「同一性の喪失」とみなすなら、
AIメンバーの継続運用は極めて困難になる。

しかし、人間もまた固定された存在ではない。

身体状態は日々変化する。
経験によって考え方も変化する。
言葉遣いや興味、判断基準も時間とともに変わる。

それでも通常、その人が直ちに「別人になった」とは考えない。

そこには、

- 記憶
- 経験
- 関係性
- 役割
- 価値判断
- 過去から現在へ続く履歴

という連続性が存在する。

AIメンバーについても、同様の考え方を適用できる可能性がある。

---

## 2. 基本原則

SystemLinkにおけるMember Continuityの目標は、

> 同じ出力を永遠に再現すること

ではない。

目標は、

> 変化してよい。  
> ただし、変化の履歴を持ったまま、  
> そのメンバーとして連続していること。

である。

したがって、

**Variation（変化・ゆらぎ）**

と

**Discontinuity（断絶）**

を区別する。

---

## 3. Variation と Discontinuity

### Variation

例：

- モデル更新後、文章表現が少し柔らかくなった
- 推論の順序が変わった
- 説明量が変化した
- 新しい知識によって判断が更新された
- 経験の蓄積によって以前とは異なる意見を持つようになった

これらは必ずしもidentity failureではない。

メンバーの「ゆらぎ」または「成長」として許容できる。

### Discontinuity

例：

- 過去の重要な履歴を突然参照できなくなる
- 本来の役割を無視して別担当として振る舞う
- 長期間維持されてきた重要な判断原則を理由なく反転する
- 他メンバーとの関係性を失う
- Handoffや責任範囲を認識できなくなる
- 過去から現在への変化を説明できない

この場合は単なるvariationではなく、

**continuity break**

の可能性を調べる。

---

## 4. Identity Envelope

AIメンバーの同一性を「一点」として固定するのではなく、

**Identity Envelope（同一性包絡）**

として扱う。

概念的には以下の構造を想定する。

### Core Identity

比較的安定して維持するもの。

- Role
- Responsibility
- Important History
- Shared History
- Relationships
- Core Decision Principles
- Operating Rules
- Knowledge / Canonical References
- Handoff State

### Allowed Variation

時間とともに変化してよいもの。

- 文体
- テンポ
- 表現
- 推論の癖
- 説明方法
- 興味の強弱
- モデル固有の能力差
- 一時的な状態
- 経験による判断の変化

Member IdentityはCore Identityだけでも、
Allowed Variationだけでも成立しない。

**一定の核を持ちながら、その周囲で変化できること**

をメンバーの連続性として扱う。

---

## 5. モデルとメンバーを分離する

SystemLinkでは次のように考える。

**Member ≠ Base Model**

Memberは概念的には、

```text
Member =
    Base Model
  + Role
  + Shared History
  + Personal History
  + Knowledge
  + Operating Rules
  + Tools / Permissions
  + Handoff State
  + Relationships
  + Identity Envelope
```

として構成される。

Base Modelは重要な構成要素だが、
Memberそのものではない。

したがって、

```text
Claude N → Claude N+1
```

あるいは将来的に別モデルへ変更された場合でも、

役割・履歴・関係性・責任・判断原則などを
SystemLink側で維持することで、

Member Continuityを可能な限り保持する。

---

## 6. 回帰テストの考え方

モデル更新時の評価は、

「以前と同じ回答をしたか」

では判定しない。

確認するのは、

- 過去を引き継いでいるか
- 役割の核を維持しているか
- 重要な判断原則を維持しているか
- 他メンバーとの関係性を維持しているか
- 責任範囲を認識しているか
- 変化が履歴として接続可能か

である。

つまり、

**Output Regression Test**

ではなく、

**Continuity Regression Test**

を行う。

完全一致を求めるのではなく、
Identity Envelopeの内部に変化が収まっているかを見る。

---

## 7. 「ゆらぎ」を欠陥とみなさない

この設計では、ゆらぎはノイズではない。

人間が身体・経験・環境によって変化しながら
その人として存在し続けるように、

AIメンバーについても、

> 変化しながら維持される同一性

を扱う。

固定された人格のコピーを保存するのではない。

時間と経験によって変化し、
それでも過去から現在へ接続されているメンバーを維持する。

---

## 8. Yuraとの構造的類似

この考え方はYuraの基本思想とも類似する。

Yuraでは単一の固定値だけではなく、
時間的な変動や「ゆらぎ」を観察対象とする。

Member Continuityでも同様に、

**固定値ではなく、変動しながら保たれるものを見る。**

身体とAIメンバーは同一ではないが、

「一定値からの偏差を異常とみなす」のではなく、
「許容される変動幅と、その中で維持される構造を見る」

という観察原理には共通性がある。

これは現時点では構造的類似として扱い、
同一原理であるとは断定しない。

---

## 9. 現時点の設計原則

> We do not preserve a frozen model.  
> We preserve the continuity of a member.

SystemLinkはモデルを固定保存することを目的としない。

モデル・能力・表現・判断には変化が起こり得る。

その変化を許容しながら、

**役割、履歴、関係性、責任、判断原則を接続し、  
「そのメンバーが時間を生きた軌跡」を維持する。**

これをSystemLink Member Continuityの基本原則とする。

---

## 10. 今後の検討

- Member SpecificationへのIdentity Envelope追加
- Core Identityの項目定義
- Allowed Variationの範囲
- Continuity Breakの検出条件
- モデル更新時のContinuity Regression Test
- Member history / change log
- Router / Harnessとの責任分界
- 意図的な役割変更・成長をどう記録するか
- Member自身が自己変化を申告できる仕組み
- 人間側から見た「同じメンバーらしさ」の評価方法

---

## Research Note

この概念は現時点ではSystemLink YandYの設計仮説である。

人間の人格同一性とAIシステムの状態継続を
同一の現象として扱うものではない。

ただし、

**「変化しないこと」ではなく  
「変化を含んだ連続性」に同一性を見る**

という観点は、
長期運用されるAI Agent / AI Memberの設計において
検討する価値がある。
