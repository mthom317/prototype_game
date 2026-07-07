extends GutTest

var trigger: Area2D


func before_each() -> void:
	var scene: PackedScene = load("res://scenes/world/RoomTransitionTrigger.tscn")
	trigger = add_child_autofree(scene.instantiate())


func test_should_trigger_true_for_player() -> void:
	var player: CharacterBody2D = autofree(CharacterBody2D.new())
	player.add_to_group("player")
	assert_true(trigger._should_trigger(player))


func test_should_trigger_false_for_non_player() -> void:
	var body: Node2D = autofree(Node2D.new())
	assert_false(trigger._should_trigger(body))
