# Godot Fundamentals (via this project's actual files)

This is a primer on Godot's core concepts, explained through the real files
in this repo rather than generic examples — read this alongside
[Player.tscn](../scenes/player/Player.tscn) and
[Player.gd](../scripts/player/Player.gd).

## Nodes and scenes

A **node** is the basic building block — everything in Godot is a node of
some type (`CharacterBody2D`, `Camera2D`, `ColorRect`, etc.), arranged in a
tree.

A **scene** is a saved, reusable node tree. `scenes/player/Player.tscn` is a
scene: its root is a `CharacterBody2D` named "Player", with three children —
a `CollisionShape2D`, a `ColorRect` (the placeholder visual), and a
`Camera2D`. Because it's saved as its own scene, it can be **instanced**
(dropped in) anywhere — which is exactly what `scenes/main/TestRoom.tscn`
does: it instances `Player.tscn` as a child, rather than duplicating all
those nodes by hand.

## CharacterBody2D vs RigidBody2D

The player uses `CharacterBody2D`, not `RigidBody2D`. `RigidBody2D` is
driven by the physics engine (forces, mass, gravity) — great for objects
that should behave "physically" (a rolling boulder, a thrown object).
`CharacterBody2D` is designed for code-driven movement: you set `velocity`
yourself and call `move_and_slide()`, and Godot handles collision response
(sliding along walls) without simulating forces. That's the right fit for
direct, responsive player control in an action game — you want "the player
moves exactly where the stick/keys say," not "the player is a physics
object that happens to be pushed around."

Look at `scripts/player/Player.gd`:

```gdscript
extends CharacterBody2D

@export var speed: float = 120.0

func _physics_process(_delta: float) -> void:
    var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
    velocity = input_vector * speed
    move_and_slide()
```

`Input.get_vector(...)` reads the four directional input actions (defined in
`project.godot`'s `[input]` section) and returns an already-normalized
`Vector2` — so diagonal movement isn't faster than cardinal movement, without
any manual normalization code. `_physics_process` (not `_process`) is used
because movement/collision should run on the fixed physics tick, not the
variable rendering framerate.

## Collision layers and masks

`project.godot`'s `[layer_names]` section names 8 physics layers used
throughout this project: `world, player, enemy, hitbox, hurtbox, item, npc,
projectile`. Every physics body has a **layer** (what it *is*, for others to
detect) and a **mask** (what it *looks for*, i.e. what it collides with).

Right now: the player has `collision_layer = 2` (it *is* on the "player"
layer) and `collision_mask = 1` (it *collides with* the "world" layer). The
boundary walls in `TestRoom.tscn` have `collision_layer = 1` ("world") and
`collision_mask = 0` (static geometry doesn't need to detect anything
itself — the player finding the wall is enough).

Layers 3–8 (enemy, hitbox, hurtbox, item, npc, projectile) are reserved now,
unused, so that M1's combat system can use `hitbox`/`hurtbox` layers without
having to renumber every existing scene's layer/mask values — renumbering
after the fact is a breaking, hard-to-audit change across every scene file.

## Signals

Signals are Godot's event system — a node emits a signal, and any other node
can "connect" a function to react to it, without the emitter needing to know
who's listening. None of our current scenes use custom signals yet, but the
pattern to expect in M1: a future `Hurtbox` node (an `Area2D`) will emit
`area_entered` when a `Hitbox` overlaps it, and the enemy/player script
listening for that signal will react (take damage, flash, etc.) — this
decouples "something can deal damage" from "something can take damage."

## Autoloads (singletons)

`project.godot`'s `[autoload]` section registers
`scripts/autoloads/GameManager.gd` as a global singleton, accessible from any
script in the project as `GameManager` without needing an explicit
reference. This is Godot's mechanism for global/persistent state that
outlives any single scene (current room, save data, player stats). Right
now `GameManager.gd` is nearly empty — it exists to establish the pattern
early, since retrofitting an autoload after many scripts already reference
scene-local state is more disruptive than starting with the hook in place.
