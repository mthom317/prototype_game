extends Node2D

## Sandbox scene for iterating on a single feature (combat, items, NPC
## interactions) without booting the full game. Spawns only the player on an
## open floor; use the debug menu (V key) to spawn whatever you're testing.

@onready var player_health: Health = $Player/Health
@onready var health_ui: HealthUI = $HUD/HealthUI


func _ready() -> void:
	SceneTransition.place_player_at_spawn(self)
	player_health.health_changed.connect(health_ui.set_health)
	health_ui.set_health(player_health.current_health, player_health.max_health)
