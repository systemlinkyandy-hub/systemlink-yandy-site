# LLM Meme Contamination Case Study — 桂（カツラ）

Date: 2026-08-23
Status: Observational case note
Scope: IACProject / conversational multimodal generation

## Purpose
This note records a project-level example of context-driven meme intrusion in LLM-assisted generation. The contaminating cultural association is labeled **桂（カツラ）**. The intended project identity is **桂（ケイ）**.

The term “meme contamination” is used here as an internal descriptive label, not as an established scientific term.

## Observed pattern
Several mutually reinforcing cues accumulated in the active context. The model increasingly generated outputs aligned with the familiar cultural association rather than the intended project identity.

Operationally, the pattern is treated as:

**strong meme cue → repeated contextual reinforcement → style / identity drift**

This is not evidence that model weights changed during the conversation. It is treated as a context-driven generation effect.

## Canonical distinction
- Canonical target: **桂（ケイ）**
- Contaminating meme label: **桂（カツラ）**

The two must be stored and referenced separately.

## Mitigation
1. Label the contaminating meme explicitly.
2. Label the canonical target separately.
3. Remove high-strength visual or verbal cues that reinforce the meme.
4. Restate the canonical project identity.
5. Mark features that must not propagate into later generations.
6. Keep the contamination path as a reusable case log.

## Practical rule
When a recognizable cultural meme begins to dominate a long-running context, do not only say “do not use this meme.” Instead, identify the specific cues, separate meme source from canonical target, remove reinforcing cues, restore the canonical identity, and log the incident.

## Summary
Case name: **桂（カツラ） meme intrusion example**

Canonical target: **桂（ケイ）**
