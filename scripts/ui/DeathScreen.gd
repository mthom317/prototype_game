extends CanvasLayer

## Global game-over overlay, registered as an autoload (see project.godot
## [autoload]) so any room's Player can trigger it via show_game_over()
## without per-scene wiring - Player.gd connects its own Health.died to
## this. Pauses the tree so gameplay freezes behind the overlay; stays
## interactive itself via PROCESS_MODE_ALWAYS so its buttons still work
## while paused.

@onready var overlay: Control = $Overlay
@onready var restart_button: Button = $Overlay/CenterContainer/VBoxContainer/RestartButton
@onready var quit_button: Button = $Overlay/CenterContainer/VBoxContainer/QuitButton


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	overlay.visible = false
	restart_button.pressed.connect(_on_restart_pressed)
	quit_button.pressed.connect(_on_quit_pressed)


func show_game_over() -> void:
	overlay.visible = true
	restart_button.grab_focus()
	get_tree().paused = true


func _on_restart_pressed() -> void:
	overlay.visible = false
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_quit_pressed() -> void:
	get_tree().quit()
