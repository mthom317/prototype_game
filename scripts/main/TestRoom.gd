extends Node2D

## Composition root: wires the player's Health to the HUD without either
## of them knowing about each other.

@onready var player_health: Health = $Player/Health
@onready var health_ui: HealthUI = $HUD/HealthUI


func _ready() -> void:
	SceneTransition.place_player_at_spawn(self)
	player_health.health_changed.connect(health_ui.set_health)
	health_ui.set_health(player_health.current_health, player_health.max_health)
