class_name PushableBlock
extends StaticBody2D

## Sits on the "world" physics layer like a wall (blocks anyone without
## boots). A player with boots pushes it one tile in whichever direction
## they walk into it, as long as the destination tile is clear.

const TILE_SIZE := 16.0

@onready var push_detector: Area2D = $PushDetector


func _ready() -> void:
	push_detector.body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if not _can_be_pushed_by(body):
		return
	var direction := _push_direction(body.global_position, global_position)
	if direction == Vector2.ZERO:
		return
	var target_position := global_position + direction * TILE_SIZE
	if _is_blocked(target_position):
		return
	global_position = target_position


## Pure: only a player with boots can push a block.
func _can_be_pushed_by(body: Node2D) -> bool:
	return body.is_in_group("player") and "has_boots" in body and body.has_boots


## Pure: which of the 4 cardinal directions the player is pushing from,
## based on whichever axis has the larger offset between the two.
func _push_direction(player_position: Vector2, block_position: Vector2) -> Vector2:
	var delta := block_position - player_position
	if delta == Vector2.ZERO:
		return Vector2.ZERO
	if absf(delta.x) > absf(delta.y):
		return Vector2(signf(delta.x), 0)
	return Vector2(0, signf(delta.y))


func _is_blocked(target_position: Vector2) -> bool:
	var space_state := get_world_2d().direct_space_state
	var query := PhysicsPointQueryParameters2D.new()
	query.position = target_position
	query.collision_mask = 1  # "world" layer
	query.exclude = [get_rid()]
	return not space_state.intersect_point(query).is_empty()
