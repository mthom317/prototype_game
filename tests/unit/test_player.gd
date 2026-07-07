extends GutTest

var player: CharacterBody2D


func before_each() -> void:
	var scene: PackedScene = load("res://scenes/player/Player.tscn")
	player = add_child_autofree(scene.instantiate())


func test_facing_suffix_mapping() -> void:
	player.facing = player.Facing.DOWN
	assert_eq(player._facing_suffix(), "down")
	player.facing = player.Facing.UP
	assert_eq(player._facing_suffix(), "up")
	player.facing = player.Facing.SIDE
	assert_eq(player._facing_suffix(), "side")


func test_update_animation_idle_when_no_input() -> void:
	player.facing = player.Facing.SIDE
	player._update_animation(Vector2.ZERO)
	assert_eq(player.animated_sprite.animation, "idle_side")


func test_update_animation_moving_right_sets_side_facing_unflipped() -> void:
	player._update_animation(Vector2(1, 0))
	assert_eq(player.facing, player.Facing.SIDE)
	assert_false(player.animated_sprite.flip_h)
	assert_eq(player.animated_sprite.animation, "move_side")


func test_update_animation_moving_left_sets_side_facing_flipped() -> void:
	player._update_animation(Vector2(-1, 0))
	assert_eq(player.facing, player.Facing.SIDE)
	assert_true(player.animated_sprite.flip_h)
	assert_eq(player.animated_sprite.animation, "move_side")


func test_update_animation_moving_up_sets_up_facing() -> void:
	player._update_animation(Vector2(0, -1))
	assert_eq(player.facing, player.Facing.UP)
	assert_eq(player.animated_sprite.animation, "move_up")


func test_update_animation_moving_down_sets_down_facing() -> void:
	player._update_animation(Vector2(0, 1))
	assert_eq(player.facing, player.Facing.DOWN)
	assert_eq(player.animated_sprite.animation, "move_down")


func test_update_animation_horizontal_input_takes_priority_over_vertical() -> void:
	player._update_animation(Vector2(1, 1))
	assert_eq(player.facing, player.Facing.SIDE)


func test_position_hitbox_up_facing() -> void:
	player.facing = player.Facing.UP
	player._position_hitbox()
	assert_eq(player.hitbox.position, Vector2(0, -player.ATTACK_HITBOX_OFFSET))


func test_position_hitbox_down_facing() -> void:
	player.facing = player.Facing.DOWN
	player._position_hitbox()
	assert_eq(player.hitbox.position, Vector2(0, player.ATTACK_HITBOX_OFFSET))


func test_position_hitbox_side_facing_unflipped() -> void:
	player.facing = player.Facing.SIDE
	player.animated_sprite.flip_h = false
	player._position_hitbox()
	assert_eq(player.hitbox.position, Vector2(player.ATTACK_HITBOX_OFFSET, 0))


func test_position_hitbox_side_facing_flipped() -> void:
	player.facing = player.Facing.SIDE
	player.animated_sprite.flip_h = true
	player._position_hitbox()
	assert_eq(player.hitbox.position, Vector2(-player.ATTACK_HITBOX_OFFSET, 0))


func test_perform_combo_hit_immediately_sets_attacking_and_enables_hitbox() -> void:
	player.facing = player.Facing.DOWN
	player._perform_combo_hit()
	assert_true(player.is_attacking)
	assert_false(player.can_attack)
	assert_true(player.hitbox.monitoring)
	assert_eq(player.animated_sprite.animation, "attack_down")
	assert_eq(player.hitbox.position, Vector2(0, player.ATTACK_HITBOX_OFFSET))
	# Drain the attack-window + combo-window coroutine before the test ends
	# so its create_timer() awaits don't keep ticking into (and skew the
	# timing of) whichever test runs next.
	await wait_seconds(player.ATTACK_DURATION + player.COMBO_WINDOW + 0.05)


func test_perform_combo_hit_ends_attack_window_after_attack_duration() -> void:
	player._perform_combo_hit()
	await wait_seconds(player.ATTACK_DURATION + 0.05)
	assert_false(player.is_attacking)
	assert_false(player.hitbox.monitoring)
	# A combo hit allows immediate chaining - no dead cooldown.
	assert_true(player.can_attack)
	await wait_seconds(player.COMBO_WINDOW + 0.05)


func test_combo_step_resets_after_window_expires_with_no_follow_up() -> void:
	player._perform_combo_hit()
	await wait_seconds(player.ATTACK_DURATION + player.COMBO_WINDOW + 0.05)
	assert_eq(player.combo_step, 0)


func test_combo_hit_damage_and_scale_by_step() -> void:
	assert_eq(player._combo_hit_damage(0), player.COMBO_HIT_DAMAGE)
	assert_eq(player._combo_hit_damage(1), player.COMBO_HIT_DAMAGE)
	assert_eq(player._combo_hit_damage(2), player.COMBO_FINISHER_DAMAGE)
	assert_eq(player._combo_hit_scale(0), 1.0)
	assert_eq(player._combo_hit_scale(1), 1.0)
	assert_eq(player._combo_hit_scale(2), player.COMBO_FINISHER_HITBOX_SCALE)


func test_next_combo_step_cycles_and_wraps() -> void:
	assert_eq(player._next_combo_step(0), 1)
	assert_eq(player._next_combo_step(1), 2)
	assert_eq(player._next_combo_step(2), 0)


func test_is_charged_hold_threshold() -> void:
	assert_false(player._is_charged_hold(player.CHARGE_THRESHOLD - 0.1))
	assert_true(player._is_charged_hold(player.CHARGE_THRESHOLD))
	assert_true(player._is_charged_hold(player.CHARGE_THRESHOLD + 0.1))


func test_three_combo_hits_in_sequence_reach_finisher_and_wrap() -> void:
	player._perform_combo_hit()
	await wait_seconds(player.ATTACK_DURATION + 0.05)
	assert_eq(player.combo_step, 1)

	player._perform_combo_hit()
	await wait_seconds(player.ATTACK_DURATION + 0.05)
	assert_eq(player.combo_step, 2)

	player._perform_combo_hit()
	assert_eq(player.hitbox.damage, player.COMBO_FINISHER_DAMAGE)
	assert_eq(player.hitbox.scale, Vector2.ONE * player.COMBO_FINISHER_HITBOX_SCALE)
	await wait_seconds(player.ATTACK_DURATION + player.COMBO_WINDOW + 0.05)
	assert_eq(player.combo_step, 0)


func test_perform_charged_hit_uses_bigger_damage_and_scale() -> void:
	player.facing = player.Facing.DOWN
	player.combo_step = 1
	player._perform_charged_hit()
	assert_eq(player.combo_step, 0)
	assert_eq(player.hitbox.damage, player.CHARGED_DAMAGE)
	assert_eq(player.hitbox.scale, Vector2.ONE * player.CHARGED_HITBOX_SCALE)
	assert_true(player.hitbox.monitoring)
	await wait_seconds(player.CHARGE_ATTACK_DURATION + player.ATTACK_COOLDOWN + 0.05)


func test_perform_charged_hit_requires_full_cooldown_before_can_attack() -> void:
	player._perform_charged_hit()
	await wait_seconds(player.CHARGE_ATTACK_DURATION + 0.05)
	assert_false(player.can_attack)
	await wait_seconds(player.ATTACK_COOLDOWN + 0.05)
	assert_true(player.can_attack)
