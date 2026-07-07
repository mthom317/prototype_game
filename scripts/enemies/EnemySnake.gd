class_name EnemySnake
extends Enemy

## Wanderer enemy: while the player is outside detection_radius, picks a
## random nearby direction on a timer and patrols (or pauses) instead of
## standing still. Switches to chasing (reusing Enemy's chase logic) as
## soon as the player is within radius.

@export var wander_speed: float = 30.0
@export var wander_interval_min: float = 1.0
@export var wander_interval_max: float = 2.5

var _wander_direction: Vector2 = Vector2.ZERO
var _time_until_next_wander: float = 0.0
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	super._ready()
	_time_until_next_wander = _rng.randf_range(wander_interval_min, wander_interval_max)


func _physics_process(delta: float) -> void:
	var direction := Vector2.ZERO

	if (
		_player != null
		and _is_player_in_range(_player.global_position - global_position, detection_radius)
	):
		var to_player := _player.global_position - global_position
		velocity = _compute_chase_velocity(to_player, detection_radius, speed)
		direction = velocity.normalized() if velocity != Vector2.ZERO else Vector2.ZERO
	else:
		_time_until_next_wander -= delta
		if _time_until_next_wander <= 0.0:
			_wander_direction = _pick_wander_direction(_rng.randf(), _rng.randf_range(-1.0, 1.0))
			_time_until_next_wander = _rng.randf_range(wander_interval_min, wander_interval_max)
		velocity = _wander_direction * wander_speed
		direction = _wander_direction

	_update_animation(direction)
	move_and_slide()


## Pure decision: is the player within the given detection radius?
## Separated so wander-vs-chase state selection is directly testable.
func _is_player_in_range(to_player: Vector2, radius: float) -> bool:
	return to_player.length() <= radius


## Pure: picks a wander direction (or Vector2.ZERO to pause) from two
## independent random inputs in [0,1) and [-1,1) respectively - a quarter
## of the time the wanderer pauses in place, otherwise it picks one of the
## 4 cardinal-ish directions derived from the sign of each random input.
func _pick_wander_direction(pause_roll: float, angle_roll: float) -> Vector2:
	if pause_roll < 0.25:
		return Vector2.ZERO
	var angle := angle_roll * PI
	return Vector2.RIGHT.rotated(angle)
