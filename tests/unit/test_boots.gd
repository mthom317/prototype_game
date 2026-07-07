extends GutTest

var player: CharacterBody2D
var boots: Boots


func before_each() -> void:
	var player_scene: PackedScene = load("res://scenes/player/Player.tscn")
	player = add_child_autofree(player_scene.instantiate())

	var boots_scene: PackedScene = load("res://scenes/items/Boots.tscn")
	boots = add_child_autofree(boots_scene.instantiate())


func test_pickup_sets_has_boots() -> void:
	assert_false(player.has_boots)
	boots._on_body_entered(player)
	assert_true(player.has_boots)


func test_pickup_frees_itself() -> void:
	boots._on_body_entered(player)
	assert_true(not is_instance_valid(boots) or boots.is_queued_for_deletion())


func test_set_on_ice_tracks_state() -> void:
	player.set_on_ice(true)
	assert_true(player._on_ice)
	player.set_on_ice(false)
	assert_false(player._on_ice)


func test_compute_movement_velocity_snaps_to_input_when_not_sliding() -> void:
	var velocity := player._compute_movement_velocity(
		Vector2(999, 999), Vector2(1, 0), 120.0, false
	)
	assert_eq(velocity, Vector2(120, 0))


func test_compute_movement_velocity_snaps_to_zero_when_not_sliding_and_no_input() -> void:
	var velocity := player._compute_movement_velocity(Vector2(999, 999), Vector2.ZERO, 120.0, false)
	assert_eq(velocity, Vector2.ZERO)


func test_compute_movement_velocity_keeps_sliding_when_no_input_while_sliding() -> void:
	var velocity := player._compute_movement_velocity(Vector2(80, 0), Vector2.ZERO, 120.0, true)
	assert_eq(velocity, Vector2(80, 0))


func test_compute_movement_velocity_steers_gradually_when_sliding_with_input() -> void:
	var velocity := player._compute_movement_velocity(Vector2(120, 0), Vector2(0, 1), 120.0, true)
	# Steered toward (0, 120) but not snapped all the way there.
	assert_almost_eq(velocity.x, 120 * (1.0 - player.ICE_STEER_FACTOR), 0.01)
	assert_almost_eq(velocity.y, 120 * player.ICE_STEER_FACTOR, 0.01)
	assert_ne(velocity, Vector2(0, 120))
