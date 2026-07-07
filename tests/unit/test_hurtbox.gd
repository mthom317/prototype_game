extends GutTest

var hurtbox: Hurtbox
var attacker: Hitbox


func before_each() -> void:
	hurtbox = add_child_autofree(Hurtbox.new())
	attacker = autofree(Hitbox.new())


func test_take_hit_emits_damaged_with_amount_and_hitbox() -> void:
	watch_signals(hurtbox)
	hurtbox.take_hit(2, attacker)
	assert_signal_emitted_with_parameters(hurtbox, "damaged", [2, attacker])


func test_take_hit_without_invincibility_allows_repeat_hits() -> void:
	hurtbox.invincibility_duration = 0.0
	watch_signals(hurtbox)
	hurtbox.take_hit(1, attacker)
	hurtbox.take_hit(1, attacker)
	assert_signal_emit_count(hurtbox, "damaged", 2)


func test_take_hit_starts_invincibility_when_duration_set() -> void:
	hurtbox.invincibility_duration = 1.0
	hurtbox.take_hit(1, attacker)
	assert_true(hurtbox.invincible)


func test_second_hit_ignored_during_invincibility_window() -> void:
	hurtbox.invincibility_duration = 1.0
	watch_signals(hurtbox)
	hurtbox.take_hit(1, attacker)
	hurtbox.take_hit(1, attacker)
	assert_signal_emit_count(hurtbox, "damaged", 1)
