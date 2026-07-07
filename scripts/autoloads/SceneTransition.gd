extends Node

## Swaps the current room for another and repositions the player at the
## entry point matching where they came from. A room needs no transition
## code beyond one call in its own _ready() - place_player_at_spawn(self) -
## and a Marker2D child named "SpawnPoint_<id>" for each id a
## RoomTransitionTrigger might send the player to. No-ops if the room was
## opened directly (e.g. via the editor or as the boot scene), since
## there's no pending spawn id in that case.

const SPAWN_POINT_PREFIX := "SpawnPoint_"

var pending_spawn_id: String = ""


func go_to(target_scene_path: String, spawn_id: String) -> void:
	pending_spawn_id = spawn_id
	get_tree().change_scene_to_file(target_scene_path)


func place_player_at_spawn(room: Node) -> void:
	var spawn_id := pending_spawn_id
	pending_spawn_id = ""
	if spawn_id.is_empty():
		return
	var player := room.get_tree().get_first_node_in_group("player")
	var spawn_point := _find_spawn_point(room, spawn_id)
	if player == null or spawn_point == null:
		return
	player.global_position = spawn_point.global_position


## Pure: looks up the Marker2D a given spawn id refers to within a room.
func _find_spawn_point(room: Node, spawn_id: String) -> Node2D:
	return room.find_child(SPAWN_POINT_PREFIX + spawn_id, true, false) as Node2D
