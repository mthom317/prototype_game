# Player Sprite: Placeholder Status

`resources/sprite_frames/player.tres` currently uses the Ninja Adventure
Asset Pack's **NinjaGreen** character (CC0, `assets/sprites/characters/actors/CharacterAnimated/NinjaGreen/`)
as a placeholder, wired in via issue #50. This replaced a solid-color
placeholder that itself replaced the original Mystic Woods sprites removed
for a license violation (see `CLAUDE.md`'s "Assets / licensing" section and
issue #8/PR #42).

## Why NinjaGreen

It's the only character in the pack with a full 4-directional (down/left/right/up)
rig across every state — Idle, Walk, Attack, Hit, and Dead all have separate
per-direction rows (`Separate/*.png`, 32x32 cells). Every other character in
`Character/*/SeparateAnim/` only has a full directional `Walk.png`; their
`Idle.png`/`Attack.png` are single-facing (one pose reused regardless of
direction). NinjaGreen was the only option that could give every one of
`Player.gd`'s animation names (`idle_/move_/attack_` + `down/up/side`, `death`)
real per-direction art instead of a reused single pose.

## Row mapping used

Confirmed by visually inspecting `Attack.png` (the clearest directional
tell — down/left/right/up poses are visually distinct there, unlike the more
subtle Idle/Walk bounce animations): row 0 = down, row 1 = left, row 2 =
right, row 3 = up. `Player.gd`'s `Facing.SIDE` uses row 2 (right) as the base
sprite, with `flip_h` for left-facing movement, matching the existing
`assets/sprites/characters/README.txt` convention.

`Dead.png` is a single 32x64 column (2 frames, one direction only) — used
as-is for the `death` animation regardless of facing.

## How it was built

Like other binary Godot resources in this project, `player.tres` was
generated via a one-off `godot --headless --script` run (not committed —
scratch tool) rather than hand-authored. It loads the four `Separate/*.png`
sheets directly via `Image.load()` (bypassing the resource import system,
so no `.import` sidecar file dependency) and slices 32x32 `Rect2i` regions
per frame per direction, baking them into `ImageTexture`s embedded in the
`.tres` — this is why the file is self-contained and doesn't `ext_resource`
the source PNGs.

## Still a placeholder

This is explicitly not final art — see issue #50 for the follow-up to
source dedicated/final character art later.
