# LLM Meme Contamination Case Study — 桂（ケイ）

Date: 2026-08-23
Status: Observational case note
Scope: IACProject / conversational multimodal generation

## 1. Purpose

This note records a concrete example of **meme contamination / meme intrusion in LLM-assisted generation** using the “桂（ケイ）” case.

The term “meme contamination” is used here as a project-level descriptive label, not as an established scientific term. The observed phenomenon is that a culturally strong meme or character association becomes disproportionately salient in the active context and begins to influence later text/image generation beyond the original intent.

## 2. Observed case

The original intent was not to create a direct parody character. During iterative discussion and image generation, several features accumulated:

- long dark hair
- Japanese clothing / haori-like styling
- the kanji 桂, read here as ケイ
- prior discussion of Gintama and Katsura-related jokes
- an Elizabeth-like shoulder mascot appearing in one generated image
- repeated language around “桂（カツラ）ではない。桂（ケイ）だ。”

As these associations accumulated, later outputs increasingly converged on a Katsura-related meme interpretation even when the intended project identity was broader and independent.

## 3. Important distinction

This was **not** treated as evidence that the model’s internal weights changed during the conversation.

The operational interpretation is narrower:

- the active context contained multiple mutually reinforcing cues,
- those cues increased the probability of outputs consistent with a familiar cultural pattern,
- subsequent outputs then added more cues, creating a feedback loop.

In this project, that loop is called **meme intrusion / meme contamination** for ease of discussion.

## 4. Failure mode

A strong cultural meme can become a local attractor in generation.

Typical sequence:

1. A few recognizable cues enter the context.
2. The model links them to a well-known cultural pattern.
3. Generated outputs add further matching cues.
4. Those new outputs re-enter the conversation context.
5. The association becomes progressively more dominant.
6. The original project identity risks being displaced by the meme-derived interpretation.

This can occur across modalities: text, image styling, naming, dialogue, role assignment, and narrative framing.

## 5. Mitigation used in this case

### A. Explicit labeling

The ambiguous name was fixed as:

> 桂（ケイ）

This separates the intended reading from the meme-associated reading 桂（カツラ）.

### B. Remove high-strength visual cues

The Elizabeth-like shoulder mascot was removed because it unnecessarily strengthened direct association with the copyrighted source work.

### C. Separate canonical identity from derivative association

The project identity remains SystemLink YandY / IACProject. Gintama-derived associations are treated as external cultural references, not canonical identity.

### D. Record the contamination path

Instead of merely instructing the model “do not do this again,” record:

- what cue entered,
- what association it triggered,
- which generated features reinforced it,
- which features should not be carried forward.

This makes later recovery easier.

### E. Use boundary labels

For future prompts or handoffs, distinguish:

- canonical project identity
- permitted reference
- temporary joke / meme
- forbidden carry-over
- derivative visual cue to remove

## 6. Practical prevention rule

When a recognizable meme begins to dominate a project context, do not only negate the meme globally.

Instead:

1. identify the specific contaminating cues,
2. remove or rename the strongest cues,
3. restate the canonical identity,
4. explicitly mark which elements must not propagate,
5. preserve the event as a case log for future prompting and review.

## 7. Why this case is useful

The “桂（ケイ）” example is easy to understand because the cultural association is strong and visible. It therefore serves as a practical training case for detecting context-driven meme intrusion before it becomes harder to distinguish from the intended project style.

This case should be referenced when reviewing:

- AI-generated character designs
- long-running multimodal conversations
- role-based agent personas
- style drift
- repeated cultural references
- canonical vs non-canonical project identity

## 8. Summary

Observed pattern:

**strong meme cue → repeated contextual reinforcement → cross-modal style/identity drift**

Mitigation:

**label → separate → remove strong cues → restore canon → log the contamination path**

Case name:

**桂（ケイ） meme intrusion example**
