extends GutTest

const HITBOX_LAYER := 8 # layer 4, "hitbox" (see project.godot [layer_names])
const HURTBOX_LAYER := 16 # layer 5, "hurtbox"

var hitbox: Hitbox
var hurtbox: Hurtbox


func before_each() -> void:
	hitbox = add_child_autofree(Hitbox.new())
	hurtbox = add_child_autofree(Hurtbox.new())


func test_on_area_entered_calls_take_hit_on_hurtbox() -> void:
	hitbox.damage = 3
	watch_signals(hurtbox)
	hitbox._on_area_entered(hurtbox)
	assert_signal_emitted_with_parameters(hurtbox, "damaged", [3, hitbox])


func test_on_area_entered_emits_hit_landed() -> void:
	watch_signals(hitbox)
	hitbox._on_area_entered(hurtbox)
	assert_signal_emitted_with_parameters(hitbox, "hit_landed", [hurtbox])


func test_on_area_entered_ignores_non_hurtbox_areas() -> void:
	var other_area: Area2D = autofree(Area2D.new())
	watch_signals(hitbox)
	hitbox._on_area_entered(other_area)
	assert_signal_not_emitted(hitbox, "hit_landed")


func test_is_same_source_false_when_source_unset() -> void:
	hurtbox.source = null
	assert_false(hitbox._is_same_source(hurtbox))


func test_is_same_source_false_when_sources_differ() -> void:
	var owner_a: Node = autofree(Node.new())
	var owner_b: Node = autofree(Node.new())
	hitbox.source = owner_a
	hurtbox.source = owner_b
	assert_false(hitbox._is_same_source(hurtbox))


func test_is_same_source_true_when_sources_match() -> void:
	var character: Node = autofree(Node.new())
	hitbox.source = character
	hurtbox.source = character
	assert_true(hitbox._is_same_source(hurtbox))


func test_on_area_entered_skips_hurtbox_with_same_source() -> void:
	var character: Node = autofree(Node.new())
	hitbox.source = character
	hurtbox.source = character
	watch_signals(hurtbox)
	watch_signals(hitbox)
	hitbox._on_area_entered(hurtbox)
	assert_signal_not_emitted(hurtbox, "damaged")
	assert_signal_not_emitted(hitbox, "hit_landed")


func _make_shape() -> CollisionShape2D:
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(16, 16)
	shape.shape = rect
	return shape


func test_overlapping_hitbox_and_hurtbox_deal_damage_via_physics() -> void:
	hitbox.collision_layer = HITBOX_LAYER
	hitbox.collision_mask = HURTBOX_LAYER
	hitbox.add_child(_make_shape())

	hurtbox.collision_layer = HURTBOX_LAYER
	hurtbox.collision_mask = 0
	hurtbox.add_child(_make_shape())

	watch_signals(hurtbox)
	await wait_physics_frames(2)

	assert_signal_emitted(hurtbox, "damaged")


func test_overlapping_hitbox_and_hurtbox_with_same_source_do_not_deal_damage_via_physics() -> void:
	var character: Node = autofree(Node.new())
	hitbox.source = character
	hurtbox.source = character

	hitbox.collision_layer = HITBOX_LAYER
	hitbox.collision_mask = HURTBOX_LAYER
	hitbox.add_child(_make_shape())

	hurtbox.collision_layer = HURTBOX_LAYER
	hurtbox.collision_mask = 0
	hurtbox.add_child(_make_shape())

	watch_signals(hurtbox)
	await wait_physics_frames(2)

	assert_signal_not_emitted(hurtbox, "damaged")
