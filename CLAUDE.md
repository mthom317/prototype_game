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

Several files under `assets/sprites/` have **"Premium Version!" watermarked directly into the pixel data** (confirmed so far: `tilesets/plains.png`, `tilesets/decor_16x16.png`, `tilesets/floors/carpet.png`, `tilesets/water1.png`, `objects/objects.png`) — these came from a mixed free/paid asset pack. Do not wire any of these into a scene; verify any unchecked file (open it / view it) before use. `assets/sprites/tilesets/basicMap.tmj` (a Tiled-authored map) depends on the watermarked `plains.png` and hasn't been imported for this reason. Status and how to extend the tileset: `notes/08-tileset-setup.md`.
