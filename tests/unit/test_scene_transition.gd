extends GutTest

var transition: Node


func before_each() -> void:
	transition = add_child_autofree(load("res://scripts/autoloads/SceneTransition.gd").new())


func test_pending_spawn_id_starts_empty() -> void:
	assert_eq(transition.pending_spawn_id, "")


func test_place_player_at_spawn_does_nothing_when_no_pending_spawn() -> void:
	var room := _build_room({"north": Vector2(10, 10)})
	var player := _add_fake_player(room, Vector2.ZERO)
	transition.place_player_at_spawn(room)
	assert_eq(player.global_position, Vector2.ZERO)


func test_place_player_at_spawn_moves_player_to_matching_marker() -> void:
	var room := _build_room({"north": Vector2(10, 20)})
	var player := _add_fake_player(room, Vector2.ZERO)
	transition.pending_spawn_id = "north"
	transition.place_player_at_spawn(room)
	assert_eq(player.global_position, Vector2(10, 20))


func test_place_player_at_spawn_clears_pending_spawn_id_after_use() -> void:
	var room := _build_room({"north": Vector2(10, 20)})
	_add_fake_player(room, Vector2.ZERO)
	transition.pending_spawn_id = "north"
	transition.place_player_at_spawn(room)
	assert_eq(transition.pending_spawn_id, "")


func test_place_player_at_spawn_does_nothing_when_marker_missing() -> void:
	var room := _build_room({})
	var player := _add_fake_player(room, Vector2(5, 5))
	transition.pending_spawn_id = "missing"
	transition.place_player_at_spawn(room)
	assert_eq(player.global_position, Vector2(5, 5))


func test_place_player_at_spawn_clears_pending_spawn_id_even_when_marker_missing() -> void:
	var room := _build_room({})
	_add_fake_player(room, Vector2.ZERO)
	transition.pending_spawn_id = "missing"
	transition.place_player_at_spawn(room)
	assert_eq(transition.pending_spawn_id, "")


func _build_room(markers: Dictionary) -> Node2D:
	var room: Node2D = add_child_autofree(Node2D.new())
	for spawn_id in markers.keys():
		var marker := Marker2D.new()
		marker.name = "SpawnPoint_%s" % spawn_id
		marker.position = markers[spawn_id]
		room.add_child(marker)
	return room


func _add_fake_player(room: Node2D, spawn_position: Vector2) -> CharacterBody2D:
	var player := CharacterBody2D.new()
	player.add_to_group("player")
	player.position = spawn_position
	room.add_child(player)
	return player
