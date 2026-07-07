extends GutTest

var player: CharacterBody2D
var potion: HealingPotion


func before_each() -> void:
	var player_scene: PackedScene = load("res://scenes/player/Player.tscn")
	player = add_child_autofree(player_scene.instantiate())

	var potion_scene: PackedScene = load("res://scenes/items/HealingPotion.tscn")
	potion = add_child_autofree(potion_scene.instantiate())


func test_pickup_increments_potion_count() -> void:
	assert_eq(player.potion_count, 0)
	potion._on_body_entered(player)
	assert_eq(player.potion_count, 1)


func test_pickup_frees_itself() -> void:
	potion._on_body_entered(player)
	assert_true(not is_instance_valid(potion) or potion.is_queued_for_deletion())


func test_should_consume_potion_false_when_count_is_zero() -> void:
	assert_false(player._should_consume_potion(0))


func test_should_consume_potion_true_when_count_positive() -> void:
	assert_true(player._should_consume_potion(1))


func test_use_item_heals_to_max_and_decrements_when_count_positive() -> void:
	player.potion_count = 1
	player.health.apply_damage(4)
	player._use_item()
	assert_eq(player.health.current_health, player.health.max_health)
	assert_eq(player.potion_count, 0)


func test_use_item_does_nothing_when_count_is_zero() -> void:
	player.potion_count = 0
	player.health.apply_damage(4)
	var health_before: int = player.health.current_health
	player._use_item()
	assert_eq(player.health.current_health, health_before)
	assert_eq(player.potion_count, 0)
