class_name EnemyMushroom
extends Enemy

## Stationary turret-style enemy: never moves, but periodically fires an
## EnemyProjectile at the player whenever they're within `detection_radius`,
## gated by `fire_cooldown`. Reuses Enemy's Health/Hurtbox/Hitbox wiring and
## facing/animation helpers (idle-only, no move_* animations needed since it
## never leaves position) - only the "chase" half of Enemy's behavior is
## overridden.

@export var fire_cooldown: float = 1.5
@export var projectile_scene: PackedScene = preload("res://scenes/enemies/EnemyProjectile.tscn")
@export var projectile_speed: float = 140.0

var _time_since_last_shot: float = 0.0


func _physics_process(delta: float) -> void:
	velocity = Vector2.ZERO
	_update_animation(Vector2.ZERO)
	move_and_slide()

	if _player == null:
		return

	_time_since_last_shot += delta
	var to_player := _player.global_position - global_position
	if _should_fire(to_player, detection_radius, _time_since_last_shot, fire_cooldown):
		_fire_at(to_player)
		_time_since_last_shot = 0.0


## Pure decision: fire only if the player is within radius AND the cooldown
## has elapsed. Kept separate from node/tree state so it's directly
## unit-testable without instancing the projectile scene.
func _should_fire(
	to_player: Vector2, radius: float, time_since_last_shot: float, cooldown: float
) -> bool:
	if to_player.length() > radius:
		return false
	return time_since_last_shot >= cooldown


func _fire_at(to_player: Vector2) -> void:
	if projectile_scene == null or to_player == Vector2.ZERO:
		return
	var projectile: EnemyProjectile = projectile_scene.instantiate()
	get_tree().current_scene.add_child(projectile)
	projectile.global_position = global_position
	projectile.direction = to_player.normalized()
	projectile.speed = projectile_speed
