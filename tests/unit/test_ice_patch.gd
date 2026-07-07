extends GutTest

var player: CharacterBody2D
var ice_patch: IcePatch


func before_each() -> void:
	var player_scene: PackedScene = load("res://scenes/player/Player.tscn")
	player = add_child_autofree(player_scene.instantiate())

	var ice_scene: PackedScene = load("res://scenes/world/IcePatch.tscn")
	ice_patch = add_child_autofree(ice_scene.instantiate())


func test_entering_sets_on_ice() -> void:
	assert_false(player._on_ice)
	ice_patch._on_body_entered(player)
	assert_true(player._on_ice)


func test_exiting_clears_on_ice() -> void:
	ice_patch._on_body_entered(player)
	ice_patch._on_body_exited(player)
	assert_false(player._on_ice)


func test_ignores_bodies_without_set_on_ice() -> void:
	var body: Node2D = autofree(Node2D.new())
	# Should not error even though Node2D has no set_on_ice method.
	ice_patch._on_body_entered(body)
	ice_patch._on_body_exited(body)
	assert_true(is_instance_valid(body))
