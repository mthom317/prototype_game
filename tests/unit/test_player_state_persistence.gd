extends GutTest

## Covers issue #67: player state (has_boots, potion_count, current health)
## must survive a room transition, not reset to the new room's Player.tscn
## defaults. Exercises both the pure GameManager snapshot/apply helpers and
## the real SceneTransition.go_to -> place_player_at_spawn flow with actual
## Player scene instances, since that's the path real gameplay takes.

var outgoing_player: CharacterBody2D
var incoming_player: CharacterBody2D


func before_each() -> void:
	var player_scene: PackedScene = load("res://scenes/player/Player.tscn")
	outgoing_player = add_child_autofree(player_scene.instantiate())
	incoming_player = add_child_autofree(player_scene.instantiate())
	GameManager.pending_player_state = {}


func after_each() -> void:
	GameManager.pending_player_state = {}
	SceneTransition.pending_spawn_id = ""


func test_snapshot_player_state_captures_boots_potions_and_health() -> void:
	outgoing_player.has_boots = true
	outgoing_player.potion_count = 3
	outgoing_player.health.apply_damage(2)

	var state := GameManager.snapshot_player_state(outgoing_player)

	assert_true(state["has_boots"])
	assert_eq(state["potion_count"], 3)
	assert_eq(state["current_health"], outgoing_player.health.max_health - 2)


func test_apply_player_state_restores_onto_new_player() -> void:
	var state := {"has_boots": true, "potion_count": 3, "current_health": 5}

	GameManager.apply_player_state(incoming_player, state)

	assert_true(incoming_player.has_boots)
	assert_eq(incoming_player.potion_count, 3)
	assert_eq(incoming_player.health.current_health, 5)


func test_apply_player_state_does_nothing_with_empty_state() -> void:
	incoming_player.has_boots = false
	incoming_player.potion_count = 0

	GameManager.apply_player_state(incoming_player, {})

	assert_false(incoming_player.has_boots)
	assert_eq(incoming_player.potion_count, 0)
	assert_eq(incoming_player.health.current_health, incoming_player.health.max_health)


func test_room_transition_preserves_player_state_end_to_end() -> void:
	# Simulate leaving a room with non-default state.
	outgoing_player.has_boots = true
	outgoing_player.potion_count = 3
	outgoing_player.health.apply_damage(2)
	var expected_health: int = outgoing_player.health.current_health

	# Snapshot before removing the outgoing player, mirroring how go_to reads
	# the still-live player right before change_scene_to_file frees the old
	# tree (including that Player instance).
	GameManager.pending_player_state = GameManager.snapshot_player_state(outgoing_player)
	remove_child(outgoing_player)
	outgoing_player.queue_free()
	SceneTransition.pending_spawn_id = ""

	var room: Node2D = add_child_autofree(Node2D.new())
	remove_child(incoming_player)
	room.add_child(incoming_player)
	SceneTransition.place_player_at_spawn(room)

	assert_true(incoming_player.has_boots)
	assert_eq(incoming_player.potion_count, 3)
	assert_eq(incoming_player.health.current_health, expected_health)


func test_place_player_at_spawn_clears_pending_state_after_restore() -> void:
	GameManager.pending_player_state = {"has_boots": true, "potion_count": 1, "current_health": 1}
	var room: Node2D = add_child_autofree(Node2D.new())
	remove_child(incoming_player)
	room.add_child(incoming_player)

	SceneTransition.place_player_at_spawn(room)

	assert_eq(GameManager.pending_player_state, {})
