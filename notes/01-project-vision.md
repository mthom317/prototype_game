# Project Vision

## Concept

A 2D top-down action-adventure game in the spirit of the original *The Legend of
Zelda* (1986): overworld exploration, room-by-room dungeons, item-gated
progression (a new item opens up previously inaccessible areas), and simple
real-time combat (melee attack, enemies with basic AI, hearts/health).

## Current scope boundary

We are in **M0: project scaffolding + vertical slice**. What exists right now:

- A player (`CharacterBody2D`) that moves in 8 directions with a following
  camera, inside one placeholder test room (`TestRoom.tscn`) built from
  `ColorRect`/`StaticBody2D` primitives — no real art yet.
- No combat, no enemies, no items, no persistence. Those are deliberately
  deferred (see [06-roadmap.md](06-roadmap.md)) until the core movement/room
  pipeline is proven and real art assets are available.

This scope boundary matters: don't be surprised the game "doesn't do
anything" yet beyond walking around a box. That's the point of this pass —
prove the editor → git → CI pipeline works before investing in gameplay
systems.

## Tone and scale

Small-to-medium in scope, not open-world. Think a handful of connected
overworld screens plus one or two short dungeons, rather than a sprawling
map. Favor finishing a small, complete loop (explore → fight → find item →
unlock new area) over building lots of half-finished systems.

## Target platform

PC first (Windows/Mac/Linux via Godot's native export templates). No
mobile or console commitment at this time — the CI pipeline currently only
exports a `Linux/X11` build for automated validation; Windows/Mac exports can
be added once code-signing/notarization needs are worked out.

## Assets

The game will use original/owned art and audio (no placeholder Zelda assets
carried over from the earlier scrapped prototype). Until real art lands,
gameplay systems are built against primitive placeholders (`ColorRect`,
solid-color shapes) so that swapping in real sprites later is a drop-in
replacement, not a rewrite.
