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
  - **Decision:** A couple of hours. Keeps the project finishable for a
    2-person side project.
- Is this primarily a learning/portfolio project, or are we aiming for
  something we'd actually release?
  - Still open — revisiting later.
- How many major areas/dungeons for v1?
  - **Decision:** 1 dungeon, gated by a single ability, plus the
    overworld. Matches the couple-hours scope and keeps M2/M3 focused.

## 2. Ability-Gated Progression (the core mechanic)

- What's the actual list of gating abilities/items? (e.g. a bomb for
  cracked walls, a grapple/hookshot for gaps, boots for pushing
  blocks/crossing ice, a stronger weapon for armored enemies)
  - **Decision:** Boots — push blocks, cross ice. Single ability for
    v1's single dungeon (see section 1).
- Is ability order strictly linear (fixed sequence, one per dungeon), or
  do we want any non-linearity/sequence-breaking potential?
  - N/A for v1 — only one ability/dungeon, so no ordering question yet.
    Revisit if v1 scope expands.
- Do abilities serve double duty (combat AND traversal, like Zelda's
  hookshot), or are traversal and combat upgrades kept separate?
  - **Decision:** Traversal/utility only. Combat stays with the sword;
    boots don't affect combat.
- Is each new ability tied to unlocking the *next* dungeon, or can some be
  found optionally in the overworld?
  - **Decision:** Found in the overworld first, then used to open/progress
    through the dungeon.

## 3. World Structure

- One connected overworld with gated regions (classic Zelda), a
  hub-and-spoke map, or something more linear/corridor-based?
  - **Decision:** Hub-and-spoke. A central hub area connects to separate
    self-contained areas (including the v1 dungeon).
- Discrete screen-by-screen rooms with hard camera cuts (NES-style) or
  smooth continuous scrolling?
  - **Decision:** Discrete rooms, hard camera cuts. Matches the existing
    `TestRoom.tscn` scaffolding and the M2 room-transition plan.
- Do we want a map/compass UI, or discovery-only navigation?
  - **Decision:** Discovery-only, no map/compass UI for v1.

## 4. Combat System

- How deep does combat go — simple directional sword swing, or
  combos/charged attacks/secondary weapons?
  - **Decision:** Combos/charged attacks on top of the existing sword
    swing (issue #5).
- Rough target for enemy variety in v1?
  - **Decision:** 3-4 enemy types across overworld + dungeon.
- How many boss fights, and do bosses specifically require the ability
  just obtained (classic Zelda dungeon-boss pattern)?
  - **Decision:** 1 boss, at the end of the single v1 dungeon, requires
    using boots (push/ice mechanic) to beat.
- Health model: discrete hearts (with heart pieces/containers) or a
  numeric HP bar?
  - **Decision:** Discrete hearts — already implemented (issue #6), no
    change.

## 5. Items & Inventory

- Consumables (bombs, arrows, potions) vs. permanent key items — do we
  want both?
  - **Decision:** Both. At least one consumable (e.g. healing item)
    alongside the permanent Boots key item.
- Currency/economy — a rupee-like currency, shops, both?
  - **Decision:** Out of scope for v1. Worth adding eventually — tracked
    as a future issue rather than built now.
- Inventory UI: item quick-select wheel/button (Zelda-style) vs. simpler
  always-equipped abilities?
  - **Decision:** Always-equipped, no inventory menu. Matches the
    discovery-only/no-map-UI direction from section 3.

## 6. Narrative & NPCs

- Towns/NPCs and side quests, or a mostly-empty, exploration-focused
  world?
  - **Decision:** Towns + side quests. Note: this is bigger than the
    couple-hours v1 scope from section 1 implies — treat side quests as
    stretch content, not blocking the core dungeon/boots loop.
- Dialogue system needs — text boxes with portraits, or minimal/no
  dialogue?
  - **Decision:** Text boxes with character portraits.
- Is the player character silent, or do they have a voice/personality?
  - **Decision:** Silent protagonist — player never speaks in dialogue.

## 7. Art & Audio Direction

- Tile size/grid (16x16, 32x32?) — affects the 320x180 base resolution
  we already locked in.
  - **Decision:** 16x16. Matches the already-imported Ninja Adventure
    asset pack (CC0, issue #8/#23), fits 320x180 as 20x11.25 tiles on
    screen. Resolves the remaining open acceptance criterion on issue #8.
- Any specific palette/art-style reference points?
  - **Decision:** Stick with the Ninja Adventure pack's existing style —
    no additional reference sourcing needed.
- Music scope — per-area themes, chiptune-style, how much original audio
  are we budgeting for?
  - **Decision:** Use the imported pack's music as-is (~26 CC0 tracks +
    jingles/SFX from issue #23) — assign existing tracks per area rather
    than commissioning original audio.

## 8. Save & Persistence

- Save points (Zelda-style) vs. autosave vs. save-anywhere?
  - **Decision:** Autosave on key events (room transition, item pickup)
    — no save-point scenes or save UI needed.
- Any post-game / New Game+ considerations, or is this out of scope
  entirely for now?
  - **Decision:** Out of scope for v1.

## 9. Team & Timeline

- How are the two of you splitting responsibilities (art vs. code, or
  both doing both)?
  - **Decision:** Both doing both — drop the horizontal
    systems/content-pipeline split from notes/06-roadmap.md; either dev
    can pick up any open issue regardless of area.
- Any rough target date, or fully open-ended?
  - **Decision:** Fully open-ended, no fixed deadline.
