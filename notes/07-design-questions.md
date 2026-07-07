# Design Questions: Ability-Gated Progression

A living document of the design decisions we need to nail down for the core
loop: 2D top-down action-adventure, ability-gated progression, in the
spirit of classic *Zelda* games. Answers get filled in here as we work
through them together — this isn't meant to be resolved in one sitting.

Each section lists the open questions. Answered items get a short
**Decision:** line with the reasoning; unanswered items stay as open
questions until we get to them.

## 1. Core Scope

- How much content are we targeting for a first complete version — a
  couple of hours, a full weekend's worth, longer?
- Is this primarily a learning/portfolio project, or are we aiming for
  something we'd actually release?
- How many major areas/dungeons for v1?

## 2. Ability-Gated Progression (the core mechanic)

- What's the actual list of gating abilities/items? (e.g. a bomb for
  cracked walls, a grapple/hookshot for gaps, boots for pushing
  blocks/crossing ice, a stronger weapon for armored enemies)
- Is ability order strictly linear (fixed sequence, one per dungeon), or
  do we want any non-linearity/sequence-breaking potential?
- Do abilities serve double duty (combat AND traversal, like Zelda's
  hookshot), or are traversal and combat upgrades kept separate?
- Is each new ability tied to unlocking the *next* dungeon, or can some be
  found optionally in the overworld?

## 3. World Structure

- One connected overworld with gated regions (classic Zelda), a
  hub-and-spoke map, or something more linear/corridor-based?
- Discrete screen-by-screen rooms with hard camera cuts (NES-style) or
  smooth continuous scrolling?
- Do we want a map/compass UI, or discovery-only navigation?

## 4. Combat System

- How deep does combat go — simple directional sword swing, or
  combos/charged attacks/secondary weapons?
- Rough target for enemy variety in v1?
- How many boss fights, and do bosses specifically require the ability
  just obtained (classic Zelda dungeon-boss pattern)?
- Health model: discrete hearts (with heart pieces/containers) or a
  numeric HP bar?

## 5. Items & Inventory

- Consumables (bombs, arrows, potions) vs. permanent key items — do we
  want both?
- Currency/economy — a rupee-like currency, shops, both?
- Inventory UI: item quick-select wheel/button (Zelda-style) vs. simpler
  always-equipped abilities?

## 6. Narrative & NPCs

- Towns/NPCs and side quests, or a mostly-empty, exploration-focused
  world?
- Dialogue system needs — text boxes with portraits, or minimal/no
  dialogue?
- Is the player character silent, or do they have a voice/personality?

## 7. Art & Audio Direction

- Tile size/grid (16x16, 32x32?) — affects the 320x180 base resolution
  we already locked in.
  - **Decision:** 16x16, matching the already-imported Ninja Adventure
    Asset Pack (see issue #8 and `notes/08-tileset-setup.md`).
- Any specific palette/art-style reference points?
- Music scope — per-area themes, chiptune-style, how much original audio
  are we budgeting for?

## 8. Save & Persistence

- Save points (Zelda-style) vs. autosave vs. save-anywhere?
- Any post-game / New Game+ considerations, or is this out of scope
  entirely for now?

## 9. Team & Timeline

- How are the two of you splitting responsibilities (art vs. code, or
  both doing both)?
- Any rough target date, or fully open-ended?
