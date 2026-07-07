extends GutTest

var enemy: Enemy


func before_each() -> void:
	var scene: PackedScene = load("res://scenes/enemies/EnemySlime.tscn")
	enemy = add_child_autofree(scene.instantiate())


func test_contact_damage_is_applied_to_hitbox_on_ready() -> void:
	assert_eq(enemy.hitbox.damage, enemy.contact_damage)


func test_compute_chase_velocity_zero_when_outside_radius() -> void:
	var to_player := Vector2(enemy.detection_radius + 10, 0)
	var velocity := enemy._compute_chase_velocity(to_player, enemy.detection_radius, enemy.speed)
	assert_eq(velocity, Vector2.ZERO)


func test_compute_chase_velocity_toward_player_when_within_radius() -> void:
	var to_player := Vector2(enemy.detection_radius - 10, 0)
	var velocity := enemy._compute_chase_velocity(to_player, enemy.detection_radius, enemy.speed)
	assert_eq(velocity, Vector2(enemy.speed, 0))


func test_compute_chase_velocity_at_exact_radius_boundary_still_chases() -> void:
	var to_player := Vector2(enemy.detection_radius, 0)
	var velocity := enemy._compute_chase_velocity(to_player, enemy.detection_radius, enemy.speed)
	assert_eq(velocity, Vector2(enemy.speed, 0))


func test_compute_chase_velocity_points_toward_player_direction() -> void:
	var to_player := Vector2(0, -30)
	var velocity := enemy._compute_chase_velocity(to_player, 60.0, 40.0)
	assert_eq(velocity, Vector2(0, -40))


func test_facing_for_direction_side_on_horizontal_movement() -> void:
	var facing := enemy._facing_for_direction(Vector2(1, 0), Enemy.Facing.DOWN)
	assert_eq(facing, Enemy.Facing.SIDE)


func test_facing_for_direction_up_on_upward_movement() -> void:
	var facing := enemy._facing_for_direction(Vector2(0, -1), Enemy.Facing.DOWN)
	assert_eq(facing, Enemy.Facing.UP)


func test_facing_for_direction_down_on_downward_movement() -> void:
	var facing := enemy._facing_for_direction(Vector2(0, 1), Enemy.Facing.UP)
	assert_eq(facing, Enemy.Facing.DOWN)


func test_facing_for_direction_unchanged_when_zero_vector() -> void:
	var facing := enemy._facing_for_direction(Vector2.ZERO, Enemy.Facing.SIDE)
	assert_eq(facing, Enemy.Facing.SIDE)


func test_facing_suffix_mapping() -> void:
	assert_eq(enemy._facing_suffix(Enemy.Facing.DOWN), "down")
	assert_eq(enemy._facing_suffix(Enemy.Facing.UP), "up")
	assert_eq(enemy._facing_suffix(Enemy.Facing.SIDE), "side")


func test_hurtbox_damage_applies_to_health() -> void:
	var starting_health := enemy.health.current_health
	enemy.hurtbox.take_hit(1, autofree(Hitbox.new()))
	assert_eq(enemy.health.current_health, starting_health - 1)


func test_died_stops_physics_and_disables_hitbox() -> void:
	enemy.health.apply_damage(enemy.health.max_health)
	assert_false(enemy.is_physics_processing())
	assert_false(enemy.hitbox.monitoring)
