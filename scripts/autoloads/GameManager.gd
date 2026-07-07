extends Node

# Global game state singleton. Intentionally minimal for the vertical slice;
# future milestones add player references, room/scene transition state, and
# save/load hooks here.

## Holds the outgoing player's persisted state across a room transition
## (see SceneTransition.go_to / place_player_at_spawn). Empty when there's
## no pending snapshot, e.g. on first boot before any transition has fired.
var pending_player_state: Dictionary = {}


## Pure: builds the snapshot dictionary from a player's current state. Kept
## separate from any node state so it's directly unit-testable and easy to
## extend with new persisted fields later.
func snapshot_player_state(player: Node) -> Dictionary:
	return {
		"has_boots": player.has_boots,
		"potion_count": player.potion_count,
		"current_health": player.health.current_health,
	}


## Applies a previously captured snapshot onto a (new) player instance.
## No-ops safely if the snapshot is empty, e.g. entering a room directly
## rather than via a transition.
func apply_player_state(player: Node, state: Dictionary) -> void:
	if state.is_empty():
		return
	player.has_boots = state.get("has_boots", player.has_boots)
	player.potion_count = state.get("potion_count", player.potion_count)
	player.health.current_health = state.get("current_health", player.health.current_health)
