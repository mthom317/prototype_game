# Milestone Roadmap

Each milestone builds on the previous one. Don't start a milestone's systems
before the one before it is working and merged — the whole point of small
milestones is to keep the game *playable* (even if tiny) at every step.

## M0 — Project scaffolding + vertical slice (this pass)

- Standalone git repo, Git LFS configured, GitHub remote wired up.
- GitHub Actions CI (lint + headless export validation).
- Folder structure conventions established.
- Player moves 8-directionally with camera follow, inside one placeholder
  test room with wall collision.
- **Done when:** the project opens in the Godot editor, the player visibly
  moves and collides with walls, and a push to `main` produces a green CI
  run with a downloadable Linux build artifact.

## M1 — Combat

- `Hitbox`/`Hurtbox` `Area2D`-based components (reusable across player and
  enemies) using the reserved `hitbox`/`hurtbox` physics layers from
  `project.godot`.
- Wire the already-reserved `attack` input action to a simple sword-swing
  attack on the player.
- One basic enemy with health, a hurtbox, and minimal AI (e.g. chase player
  within a radius).
- **Depends on:** M0's collision layer scheme and Player.gd structure.

## M2 — Tilemap world

- Replace `ColorRect`/`StaticBody2D` placeholders with a real `TileSet` once
  art assets exist.
- Multi-room overworld with room-to-room transitions (classic Zelda-style
  screen transitions), likely via `Area2D` triggers + a `SceneTransition`
  autoload.
- **Depends on:** M0's `TestRoom.tscn` structure as the template for
  additional rooms; M1 is not a hard dependency but is easier to test with a
  bigger world.

## M3 — Items & inventory

- Pickup items (`Area2D` + a `resources/items/*.tres` data-resource
  pattern), an inventory UI, and item-gated progression (e.g. a key opening
  a previously locked door, matching the genre's core loop).
- **Depends on:** M2's multi-room world (gating only matters once there's
  more than one room).

## M4 — Save/load

- Persist player state, inventory, and current room using Godot's
  `ConfigFile` or JSON via `FileAccess`.
- **Depends on:** M3's inventory model existing to actually have state worth
  saving.

## M5 — Polish

- Audio (sfx/music), UI/menus (title screen, pause menu), game-feel touches
  (screen shake, hit-stop, particles).
- **Depends on:** everything above being functionally complete — polish
  last, not first.
