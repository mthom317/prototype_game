extends Node2D

## Composition root for the hub world. Places the player at the correct
## spawn point when arriving via a RoomTransitionTrigger from another room.


func _ready() -> void:
	SceneTransition.place_player_at_spawn(self)
