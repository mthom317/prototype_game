# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

A 2D top-down action-adventure game (Zelda-like, ability-gated progression) built in **Godot 4.7**, developed by two people from different devices. See `notes/01-project-vision.md` for scope/vision and `notes/06-roadmap.md` for the milestone plan. Design decisions in progress are tracked in `notes/07-design-questions.md`.

## Commands

Godot binary (macOS): `/Applications/Godot.app/Contents/MacOS/Godot`. There is no traditional build step — these are the equivalent checks:

```bash
# Headless smoke test: project + all scenes parse and load without errors.
# Run from the project root. A clean run has no ERROR/SCRIPT ERROR/Parse Error lines.
godot --headless --path . --quit

# GDScript lint/format (matches CI's `lint` job exactly)
pip install "gdtoolkit==4.*"
gdformat --check --diff scripts/
gdlint scripts/

# One-off Godot-API validation script (see "Testing patterns" below for why
# this is the standard way to verify scene/resource changes)
godot --headless --path . --script /path/to/validate_something.gd
```

New clone / new machine setup:
```bash
brew install git-lfs && git lfs install   # required once per machine, not just per repo
gh auth login                              # for PR/issue workflow
gh auth refresh -s workflow                # only needed if pushing changes to .github/workflows/
```

## Git / GitHub workflow

`main` is protected: **no direct pushes, PR required, both CI checks (`Lint GDScript`, `Headless Export Validation`) must pass before merge.** No mandatory human review (`required_approving_review_count: 0`) — either dev can self-merge once CI is green. This applies to everyone including repo admins.

- Branch per issue: `feature/5-player-attack-action`, `fix/...`, `docs/...`, `chore/...`.
- Reference the issue with `Closes #N` in the PR body — **one issue per line, exactly**. `Closes #9 and #10` or `Closes part of #10` will NOT create the linked-issue relationship GitHub's Development panel shows; each needs its own `Closes #N` line. If a PR only partially closes an issue, don't use the closing keyword at all until a follow-up PR actually finishes it (or add `Closes #N` on whichever PR completes it, retroactively editing the PR body works fine, even after merge).
- Squash-merge to keep `main` linear.
- Full detail: `notes/04-git-github-workflow.md`. Issue tracking conventions (labels, milestones, coarse-grained one-issue-per-feature philosophy): same file + `notes/06-roadmap.md`.

## Architecture

### Folder structure

`scenes/` and `scripts/` mirror each other by domain (`player/`, `combat/`, `autoloads/`, `ui/`, `hazards/`, `main/`). `assets/` holds raw LFS-tracked binaries (art/audio); `resources/` holds Godot-native `.tres` data resources (SpriteFrames, TileSets) — these are plain text, not LFS-tracked. Full rationale: `notes/03-folder-structure.md`.

### Physics layers (defined in `project.godot`, `[layer_names]`)

```
1=world  2=player  3=enemy  4=hitbox  5=hurtbox  6=item  7=npc  8=projectile
```
All reserved up front so new systems don't require renumbering existing scenes' `collision_layer`/`collision_mask` values.

### Combat system

`scripts/combat/{Hitbox,Hurtbox,Health}.gd` — small, decoupled `Area2D`/`Node` components used by both the player and (eventually) enemies:
- `Hitbox` (layer 4, mask 5): exported `damage`, calls `hurtbox.take_hit()` on overlap, emits `hit_landed`.
- `Hurtbox` (layer 5): reports damage via `damaged` signal, doesn't know who deals it; supports `invincibility_duration` (disables `monitorable` temporarily).
- `Health` (plain `Node`, not physics): `apply_damage`/`heal`, emits `health_changed`/`died`. Reusable by player or enemies alike.

Something taking damage owns a `Health` + `Hurtbox` and connects `hurtbox.damaged` to apply it to `health`. Something dealing damage owns/spawns a `Hitbox` and toggles its `monitoring` on/off for an attack window rather than adding/removing the node.

### Player (`scripts/player/Player.gd`)

`CharacterBody2D` using `Input.get_vector()` + `move_and_slide()`. Facing is tracked as an enum (`DOWN`/`UP`/`SIDE`) with `AnimatedSprite2D.flip_h` used for left vs. right (the sprite sheets only have "side" frames facing right — see `assets/sprites/characters/README.txt` for the row layout convention: idle/move/attack/[damaged]/death x down/up/side). Animation names follow `<state>_<direction>`, e.g. `attack_side`. New player states (dash, block, etc.) should follow this same facing/animation-name pattern.

The player's movement `CollisionShape2D` (`Player.tscn`) is deliberately smaller than a tile and offset toward the sprite's feet, not centered on the sprite — the 32x32 character art is drawn taller than the 16x16 tile grid, so only the feet actually occupy floor space; the head/torso are visual height that should be free to overlap tall tiles (trees, roofs) without triggering collision. This is also what makes Y-sorting (below) look correct — if the hitbox covered the full sprite, walking "behind" a tall object would be physically impossible. Keep the shape's footprint close to one tile (roughly tile-width or narrower) so the player can pass through single-tile gaps; an oversized/over-offset hitbox causes the player to visually stand in one cell while colliding as if standing in the cell below. Note `Hurtbox` currently shares this same shape resource — resizing one resizes both, so split them onto separate `RectangleShape2D` resources first if movement feel and combat hit-taking need to be tuned independently.

### Multi-room scenes & room transitions

`scripts/autoloads/SceneTransition.gd` (autoload) swaps rooms and repositions the player. Each room scene needs:
- A root script whose `_ready()` calls `SceneTransition.place_player_at_spawn(self)` (see `scripts/main/HubWorld.gd` for the minimal example) — without this, arriving via a transition trigger silently leaves the player at whatever position the scene file hardcodes, ignoring where they entered from.
- A `Marker2D` per incoming connection, named `SpawnPoint_<id>`, matching some other room's `RoomTransitionTrigger.target_spawn_id`.
- At least one `Player.tscn` instance in the scene tree (in the `player` group) — a room with a working transition trigger but no `Player` node will swap scenes into an empty, uncontrollable room.

Doorways/exits are instances of `scenes/world/RoomTransitionTrigger.tscn` (not hand-built `Area2D`s) — it already bundles the correct `collision_layer`/`collision_mask` (player-only, layer 2), a 16x16 `CollisionShape2D`, and a semi-transparent `ColorRect` so triggers are visible in the editor. Set `target_scene_path` and `target_spawn_id` per instance. Place the corresponding `SpawnPoint_<id>` a tile or more away from the return trigger in the destination room, not on top of it — spawning directly inside another trigger's shape fires it immediately (an instant bounce back).

### Tile collision & Y-sorting

Collision lives on the **tile definition** inside a `TileSet` resource, not on the `TileMapLayer` painting it — any `TileMapLayer` referencing that same `TileSet` inherits the same solid/non-solid tiles. Two things must both be true for a tile to actually block movement, and each is set in a different place in the editor: (1) the `TileSet` resource needs a Physics Layer added (Inspector → Tile Set property → unfold **Physics Layers** → **Add Element**), and (2) the specific tile needs a collision polygon drawn on that layer (TileSet bottom panel → **Select** mode → click the tile → **Physics Layer** section — press **F** for a default full-tile rectangle). A tile with a polygon but no Physics Layer on its `TileSet` looks configured but does nothing at runtime.

If two `TileMapLayer`s share one `TileSet` (e.g. via the shared `resources/tilesets/room_tileset.tres`) but only one of them should have solid tiles, give the one needing collision its **own isolated `TileSet`** (duplicate just the sources/tiles it uses into a scene-embedded `TileSet`, as done for `HubWorld.tscn`'s `Walls`/`NatureNBuildings` layers) rather than adding collision to the shared resource — otherwise every layer painting that same tile art becomes solid too.

For multi-tile tall objects (a tree's canopy spanning several cells, a building's roof + wall rows), only the **bottom-most tile of each vertical stack** should have a collision polygon — the tiles above it are visual height the player should be able to walk behind, not floor space. Combine this with **Y Sort Enabled** (on the common parent of the `Player` and the relevant `TileMapLayer`s — `Player` needs to be a sibling under that same parent, not nested deeper) and a per-tile **Y Sort Origin** (same per-tile inspector as the physics layer, set near the tile's visual base) so draw order flips correctly as the player moves above/below an object's base.

### Rendering

Renderer is **Compatibility** (`gl_compatibility`), not Forward+ — deliberately, due to a recurring Godot/macOS-Metal engine bug hitting Forward+'s compute-pipeline path even in scenes with no 3D/lighting content (see `git log` around the renderer switch commit for the exact error signature). Don't switch back to Forward+ without re-testing on macOS.

### Testing patterns (headless, no GUI available)

Godot resources with binary/nested data (`.tscn` tile_map_data, `SpriteFrames` frame arrays, `TileSet` atlas+collision config) are **generated via one-off GDScript run through `godot --headless --script`**, using the scripting API (`ResourceSaver.save()`, `PackedScene.pack()`, `TileSet`/`TileSetAtlasSource`/`SpriteFrames` methods) rather than hand-authored — the binary/nested formats are too easy to get subtly wrong by hand. These generator scripts are scratch tools, not committed to the repo; the resulting `.tres`/`.tscn` output is what's committed.

Known harness gotchas when writing a validation `.gd` script for `--script`:
- `@onready var x = $Node` doesn't populate in a bare `SceneTree._init()` — `_ready()` never fires without a processed frame. Either assign the node reference directly (`instance.x = instance.get_node("Node")`) or use `_initialize()` with `await process_frame`.
- `get_tree()` inside an instantiated node returns null under the same `_init()` limitation — code under test that calls `get_tree().create_timer(...)` etc. can only have its synchronous prefix (everything before the first `await`) tested this way; the actual timer/async behavior needs a real playtest.
- Godot's `--headless --quit` won't import newly-added assets or rebuild the global script class cache (for new `class_name` scripts) on a fresh pull — run `godot --headless --editor --quit-after 60 --path .` once first if you hit "Could not find type X in current scope" or missing-resource errors after pulling new files.
- A real (non-headless) run can still render a screenshot for visual sanity-checking without a human at the GUI: instantiate the scene, `await process_frame` a few times, then `root.get_texture().get_image().save_png(...)`. Useful since Claude can view the resulting PNG directly.

### CI/CD (`.github/workflows/ci.yml`)

Two jobs: `lint` (plain `ubuntu-latest`, gdtoolkit) and `export` (runs inside `barichello/godot-ci:4.7` — pin this tag to the actual installed Godot version, never `:latest`). The export job sets `HOME: /root` explicitly, because GitHub Actions remaps `$HOME` to `/github/home` in container jobs but this image's export templates live at `/root/.local/share/godot/...` — omitting this breaks the export step. Full writeup: `notes/05-cicd-pipeline.md`.

## Assets / licensing

Every asset under `assets/` must have a confirmed, redistribution-safe license before it's committed — this repo is **public**, so committing raw source files counts as redistribution even if the game itself is never released.

- **Ninja Adventure Asset Pack** (`assets/sprites/characters/actors/`, `backgrounds/pack/`, `items/pack/`, `effects/pack/`, `audio/pack/`, `sprites/ui/`) — confirmed CC0/public domain, no attribution required, redistribution explicitly permitted. See `assets/ASSET_PACK_LICENSE.txt` / `ASSET_PACK_README.md`.
- **Tileset** (`assets/sprites/tilesets/grass.png`, `assets/sprites/tilesets/walls/walls.png`) — traces to a confirmed CC0 pack on OpenGameArt (ArMM1998); these are the only two files from that original mixed pack kept after a license audit. The rest of that pack (several premium-watermarked files plus other unattributed files with no confirmed license) was removed — don't re-add anything from that source without confirming its license first. Status and how to extend the tileset: `notes/08-tileset-setup.md`.

**Before adding any new asset pack:** confirm the license explicitly (don't assume free-to-download means free-to-redistribute — see the Mystic Woods incident: its "Premium Version!"-style restriction was actually "no redistribution, even modified," on both free and paid tiers, which is why the original player/skeleton/slime sprites were pulled and `Player.tscn` now uses a generated placeholder `SpriteFrames` until replacement art is sourced). Document the license the same way the Ninja Adventure pack is documented, and verify with the `Read` tool / open the file before wiring anything in.
