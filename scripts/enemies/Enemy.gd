class_name Enemy
extends CharacterBody2D

## Reusable enemy base: health/hurtbox/hitbox wiring shared with the player,
## plus simple chase-within-radius AI. Individual enemy types (scenes) set
## the exported stats and swap the SpriteFrames/collision shape - this
## script has no enemy-specific art or numbers baked in.

enum Facing { DOWN, UP, SIDE }

@export var speed: float = 60.0
@export var detection_radius: float = 80.0
@export var contact_damage: int = 1

var facing: Facing = Facing.DOWN
var _player: Node2D = null

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health: Health = $Health
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var hitbox: Hitbox = $Hitbox


func _ready() -> void:
	hurtbox.damaged.connect(_on_hurtbox_damaged)
	health.died.connect(_on_died)
	hitbox.damage = contact_damage
	hitbox.source = self
	hurtbox.source = self
	_player = get_tree().get_first_node_in_group("player")


func _physics_process(_delta: float) -> void:
	var direction := Vector2.ZERO
	if _player != null:
		var to_player := _player.global_position - global_position
		velocity = _compute_chase_velocity(to_player, detection_radius, speed)
		direction = velocity.normalized() if velocity != Vector2.ZERO else Vector2.ZERO
	else:
		velocity = Vector2.ZERO

	_update_animation(direction)
	move_and_slide()


## Pure decision: chase the player if within radius, otherwise stay put.
## Kept separate from node/tree state so it's directly unit-testable.
func _compute_chase_velocity(to_player: Vector2, radius: float, move_speed: float) -> Vector2:
	if to_player.length() > radius:
		return Vector2.ZERO
	return to_player.normalized() * move_speed


func _on_hurtbox_damaged(amount: int, _hitbox: Hitbox) -> void:
	health.apply_damage(amount)


func _on_died() -> void:
	set_physics_process(false)
	hitbox.monitoring = false
	var tween := create_tween()
	tween.tween_property(animated_sprite, "modulate:a", 0.0, 0.3)
	await tween.finished
	queue_free()


func _update_animation(direction: Vector2) -> void:
	facing = _facing_for_direction(direction, facing)
	if direction == Vector2.ZERO:
		animated_sprite.play("idle_" + _facing_suffix(facing))
		return
	if facing == Facing.SIDE:
		animated_sprite.flip_h = direction.x < 0
	animated_sprite.play("move_" + _facing_suffix(facing))


## Pure: given a movement direction (or Vector2.ZERO to keep facing
## unchanged), returns the new facing. Side by default flip_h in play
## logic; the direction alone decides down/up/side/unchanged.
func _facing_for_direction(direction: Vector2, current_facing: Facing) -> Facing:
	if direction == Vector2.ZERO:
		return current_facing
	if direction.x != 0:
		return Facing.SIDE
	if direction.y < 0:
		return Facing.UP
	return Facing.DOWN


func _facing_suffix(for_facing: Facing) -> String:
	match for_facing:
		Facing.UP:
			return "up"
		Facing.SIDE:
			return "side"
		_:
			return "down"
