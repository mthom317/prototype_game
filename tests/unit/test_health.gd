extends GutTest

var health: Health


func before_each() -> void:
	health = add_child_autofree(Health.new())


func test_starts_at_max_health() -> void:
	assert_eq(health.current_health, health.max_health)


func test_apply_damage_reduces_current_health() -> void:
	health.apply_damage(3)
	assert_eq(health.current_health, health.max_health - 3)


func test_apply_damage_clamps_at_zero() -> void:
	health.apply_damage(health.max_health + 5)
	assert_eq(health.current_health, 0)


func test_apply_damage_does_nothing_once_dead() -> void:
	health.apply_damage(health.max_health)
	watch_signals(health)
	health.apply_damage(1)
	assert_eq(health.current_health, 0)
	assert_signal_not_emitted(health, "health_changed")


func test_died_emitted_exactly_once_at_zero_health() -> void:
	watch_signals(health)
	health.apply_damage(health.max_health)
	assert_signal_emit_count(health, "died", 1)


func test_died_not_emitted_while_health_remains() -> void:
	watch_signals(health)
	health.apply_damage(health.max_health - 1)
	assert_signal_not_emitted(health, "died")


func test_health_changed_emits_with_current_and_max() -> void:
	watch_signals(health)
	health.apply_damage(2)
	assert_signal_emitted_with_parameters(
		health, "health_changed", [health.max_health - 2, health.max_health]
	)


func test_heal_clamps_at_max_health() -> void:
	health.apply_damage(1)
	health.heal(999)
	assert_eq(health.current_health, health.max_health)


func test_heal_increases_current_health() -> void:
	health.apply_damage(5)
	health.heal(2)
	assert_eq(health.current_health, health.max_health - 3)
