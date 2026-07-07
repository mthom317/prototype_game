extends Node

## Swaps the current room for another and repositions the player at the
## entry point matching where they came from. A room needs no transition
## code beyond one call in its own _ready() - place_player_at_spawn(self) -
## and a Marker2D child named "SpawnPoint_<id>" for each id a
## RoomTransitionTrigger might send the player to. No-ops if the room was
## opened directly (e.g. via the editor or as the boot scene), since
## there's no pending spawn id in that case.
##
## The outgoing player's has_boots/potion_count/current_health are snapshotted
## (via GameManager) right before the scene swap and restored onto the new
## room's player inside place_player_at_spawn, since change_scene_to_file
## frees the whole tree - including the room-baked Player node - and the new
## room's Player.tscn instance starts back at its scene defaults otherwise.

const SPAWN_POINT_PREFIX := "SpawnPoint_"

var pending_spawn_id: String = ""


func go_to(target_scene_path: String, spawn_id: String) -> void:
	pending_spawn_id = spawn_id
	var player := get_tree().get_first_node_in_group("player")
	if player != null:
		GameManager.pending_player_state = GameManager.snapshot_player_state(player)
	get_tree().change_scene_to_file(target_scene_path)


func place_player_at_spawn(room: Node) -> void:
	var spawn_id := pending_spawn_id
	pending_spawn_id = ""

	var player := room.get_tree().get_first_node_in_group("player")
	if player != null:
		GameManager.apply_player_state(player, GameManager.pending_player_state)
		GameManager.pending_player_state = {}

	if spawn_id.is_empty():
		return
	var spawn_point := _find_spawn_point(room, spawn_id)
	if player == null or spawn_point == null:
		return
	player.global_position = spawn_point.global_position


## Pure: looks up the Marker2D a given spawn id refers to within a room.
func _find_spawn_point(room: Node, spawn_id: String) -> Node2D:
	return room.find_child(SPAWN_POINT_PREFIX + spawn_id, true, false) as Node2D
