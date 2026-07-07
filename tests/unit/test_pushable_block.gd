extends GutTest

const TILE_SIZE := 16.0

var block: PushableBlock


func before_each() -> void:
	var scene: PackedScene = load("res://scenes/world/PushableBlock.tscn")
	block = add_child_autofree(scene.instantiate())
	block.global_position = Vector2(100, 100)


func test_can_be_pushed_by_player_with_boots() -> void:
	var player := _make_player(true)
	assert_true(block._can_be_pushed_by(player))


func test_cannot_be_pushed_by_player_without_boots() -> void:
	var player := _make_player(false)
	assert_false(block._can_be_pushed_by(player))


func test_cannot_be_pushed_by_non_player() -> void:
	var body: Node2D = autofree(Node2D.new())
	assert_false(block._can_be_pushed_by(body))


func test_push_direction_right() -> void:
	var direction := block._push_direction(Vector2(84, 100), Vector2(100, 100))
	assert_eq(direction, Vector2(1, 0))


func test_push_direction_left() -> void:
	var direction := block._push_direction(Vector2(116, 100), Vector2(100, 100))
	assert_eq(direction, Vector2(-1, 0))


func test_push_direction_down() -> void:
	var direction := block._push_direction(Vector2(100, 84), Vector2(100, 100))
	assert_eq(direction, Vector2(0, 1))


func test_push_direction_up() -> void:
	var direction := block._push_direction(Vector2(100, 116), Vector2(100, 100))
	assert_eq(direction, Vector2(0, -1))


func test_push_direction_zero_when_positions_match() -> void:
	var direction := block._push_direction(Vector2(100, 100), Vector2(100, 100))
	assert_eq(direction, Vector2.ZERO)


func test_moves_one_tile_when_pushed_by_booted_player_with_clear_path() -> void:
	var player := _make_player(true)
	player.global_position = block.global_position + Vector2(-TILE_SIZE, 0)
	await wait_physics_frames(1)

	block._on_body_entered(player)

	assert_eq(block.global_position, Vector2(100 + TILE_SIZE, 100))


func test_push_detector_fires_via_physics_when_player_walks_into_block() -> void:
	# Regression: PushDetector previously reused the exact same shape and
	# position as the block's own solid CollisionShape2D. The player's
	# collision response stops them flush at that boundary before their
	# shape can ever overlap the (congruent) detector, so body_entered
	# never fired in real gameplay - even though _on_body_entered() worked
	# fine when called directly, as every other test in this file does.
	var player := _make_player(true)
	player.global_position = block.global_position + Vector2(-TILE_SIZE - 20, 0)

	watch_signals(block.push_detector)
	for i in range(60):
		player.velocity = Vector2(60, 0)
		player.move_and_slide()
		await wait_physics_frames(1)

	assert_signal_emitted(block.push_detector, "body_entered")
	assert_gt(block.global_position.x, 100.0)


func test_does_not_move_when_pushed_without_boots() -> void:
	var player := _make_player(false)
	player.global_position = block.global_position + Vector2(-TILE_SIZE, 0)
	await wait_physics_frames(1)

	block._on_body_entered(player)

	assert_eq(block.global_position, Vector2(100, 100))


func test_does_not_move_when_destination_is_blocked() -> void:
	var wall: StaticBody2D = add_child_autofree(StaticBody2D.new())
	wall.collision_layer = 1
	var wall_shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(TILE_SIZE, TILE_SIZE)
	wall_shape.shape = rect
	wall.add_child(wall_shape)
	wall.global_position = block.global_position + Vector2(TILE_SIZE, 0)

	var player := _make_player(true)
	player.global_position = block.global_position + Vector2(-TILE_SIZE, 0)
	await wait_physics_frames(2)

	block._on_body_entered(player)

	assert_eq(block.global_position, Vector2(100, 100))


func _make_player(has_boots: bool) -> CharacterBody2D:
	var scene: PackedScene = load("res://scenes/player/Player.tscn")
	var player: CharacterBody2D = add_child_autofree(scene.instantiate())
	player.has_boots = has_boots
	return player
