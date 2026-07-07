extends GutTest

var mushroom: EnemyMushroom
var snake: EnemySnake


func before_each() -> void:
	var mushroom_scene: PackedScene = load("res://scenes/enemies/EnemyMushroom.tscn")
	mushroom = add_child_autofree(mushroom_scene.instantiate())
	var snake_scene: PackedScene = load("res://scenes/enemies/EnemySnake.tscn")
	snake = add_child_autofree(snake_scene.instantiate())


# --- EnemyMushroom (stationary turret) ---


func test_mushroom_does_not_fire_when_player_out_of_range() -> void:
	var to_player := Vector2(mushroom.detection_radius + 10, 0)
	var should_fire := mushroom._should_fire(
		to_player, mushroom.detection_radius, 999.0, mushroom.fire_cooldown
	)
	assert_false(should_fire)


func test_mushroom_does_not_fire_before_cooldown_elapses() -> void:
	var to_player := Vector2(mushroom.detection_radius - 10, 0)
	var should_fire := mushroom._should_fire(
		to_player, mushroom.detection_radius, 0.1, mushroom.fire_cooldown
	)
	assert_false(should_fire)


func test_mushroom_fires_when_in_range_and_cooldown_elapsed() -> void:
	var to_player := Vector2(mushroom.detection_radius - 10, 0)
	var should_fire := mushroom._should_fire(
		to_player, mushroom.detection_radius, mushroom.fire_cooldown, mushroom.fire_cooldown
	)
	assert_true(should_fire)


func test_mushroom_fires_at_exact_radius_boundary() -> void:
	var to_player := Vector2(mushroom.detection_radius, 0)
	var should_fire := mushroom._should_fire(
		to_player, mushroom.detection_radius, mushroom.fire_cooldown, mushroom.fire_cooldown
	)
	assert_true(should_fire)


func test_mushroom_contact_damage_is_applied_to_hitbox_on_ready() -> void:
	assert_eq(mushroom.hitbox.damage, mushroom.contact_damage)


func test_mushroom_died_stops_physics_and_disables_hitbox() -> void:
	mushroom.health.apply_damage(mushroom.health.max_health)
	assert_false(mushroom.is_physics_processing())
	assert_false(mushroom.hitbox.monitoring)


# --- EnemySnake (wanderer) ---


func test_snake_is_not_in_range_outside_detection_radius() -> void:
	var to_player := Vector2(snake.detection_radius + 10, 0)
	assert_false(snake._is_player_in_range(to_player, snake.detection_radius))


func test_snake_is_in_range_within_detection_radius() -> void:
	var to_player := Vector2(snake.detection_radius - 10, 0)
	assert_true(snake._is_player_in_range(to_player, snake.detection_radius))


func test_snake_is_in_range_at_exact_boundary() -> void:
	var to_player := Vector2(snake.detection_radius, 0)
	assert_true(snake._is_player_in_range(to_player, snake.detection_radius))


func test_snake_wander_direction_pauses_on_low_roll() -> void:
	var direction := snake._pick_wander_direction(0.1, 0.5)
	assert_eq(direction, Vector2.ZERO)


func test_snake_wander_direction_moves_on_high_roll() -> void:
	var direction := snake._pick_wander_direction(0.9, 0.0)
	assert_almost_eq(direction.x, 1.0, 0.0001)
	assert_almost_eq(direction.y, 0.0, 0.0001)


func test_snake_wander_direction_is_normalized() -> void:
	var direction := snake._pick_wander_direction(0.5, 0.3)
	assert_almost_eq(direction.length(), 1.0, 0.0001)


func test_snake_chase_velocity_matches_base_enemy_logic() -> void:
	var to_player := Vector2(snake.detection_radius - 10, 0)
	var velocity := snake._compute_chase_velocity(to_player, snake.detection_radius, snake.speed)
	assert_eq(velocity, Vector2(snake.speed, 0))


func test_snake_contact_damage_is_applied_to_hitbox_on_ready() -> void:
	assert_eq(snake.hitbox.damage, snake.contact_damage)


func test_snake_died_stops_physics_and_disables_hitbox() -> void:
	snake.health.apply_damage(snake.health.max_health)
	assert_false(snake.is_physics_processing())
	assert_false(snake.hitbox.monitoring)
