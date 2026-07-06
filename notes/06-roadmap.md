# Milestone Roadmap

Each milestone builds on the previous one. Don't start a milestone's systems
before the one before it is working and merged — the whole point of small
milestones is to keep the game *playable* (even if tiny) at every step.

## Suggested division of labor (2 devs, no art skill, large asset library)

Neither of you is an artist, but "art" work here is really **asset
integration** work — sourcing/license-checking packs, slicing spritesheets,
building `TileSet` resources, setting import presets for crisp pixel art —
which is a learnable, non-artistic skill in its own right.

Rather than splitting by milestone (one person owns M1, the other M2), split
**horizontally by layer**, since M1 and M2 don't hard-depend on each other
(see each milestone's "Depends on" line below) and can run in parallel right
now:

- **Systems/gameplay dev**: combat logic, ability logic, save system — code
  that doesn't care what the sprites look like. Starts on M1 now (issues
  [#4](https://github.com/mthom317/prototype_game/issues/4)–[#7](https://github.com/mthom317/prototype_game/issues/7)
  on the [Project board](https://github.com/users/mthom317/projects/1)).
- **Content pipeline dev**: asset sourcing, TileSet/import setup, wiring
  sprites onto the scenes the other dev already scaffolded (`Player.tscn`,
  future enemy scenes). Starts on M2's asset groundwork now (issues
  [#8](https://github.com/mthom317/prototype_game/issues/8)–[#10](https://github.com/mthom317/prototype_game/issues/10)).

This works because a scene's visual node (`Sprite2D`/`AnimatedSprite2D`) is
separate from its collision/script logic — reskinning `Player.tscn` doesn't
touch `Player.gd`, so both workstreams land in mostly non-overlapping files
and merge cleanly. Swap roles per milestone if you'd rather both get
exposure to both kinds of work — the split is about parallelizing right now,
not a permanent assignment.

Track work via [GitHub Issues](https://github.com/mthom317/prototype_game/issues)
(one issue per feature, milestones mirror M1–M5 below) and the
[Project board](https://github.com/users/mthom317/projects/1) for an
at-a-glance view of who's working on what — useful since you're remote from
each other. See `notes/04-git-github-workflow.md` for how issues connect to
the branch/PR flow.

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
