extends Area2D

## Placed at a room's edge/doorway. Walking into it (as the player) sends
## the player to target_scene_path, positioned at the Marker2D there named
## "SpawnPoint_<target_spawn_id>" (see SceneTransition). target_scene_path
## is a plain path (not an exported PackedScene) so that two rooms can
## point back at each other without a circular ext_resource load.

@export_file("*.tscn") var target_scene_path: String
@export var target_spawn_id: String = ""


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if not _should_trigger(body):
		return
	SceneTransition.go_to(target_scene_path, target_spawn_id)


## Pure: only the player triggers a room transition.
func _should_trigger(body: Node2D) -> bool:
	return body.is_in_group("player")
