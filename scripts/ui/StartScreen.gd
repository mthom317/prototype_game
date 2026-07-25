extends Control

## Title screen shown on launch (see project.godot run/main_scene). "Play"
## starts a fresh run in the hub world; "Quit" exits the game. No
## new-game/continue split yet - that's the main menu issue (#48).

const GAMEPLAY_SCENE_PATH := "res://scenes/main/HubWorld.tscn"

@onready var play_button: Button = $CenterContainer/VBoxContainer/PlayButton
@onready var quit_button: Button = $CenterContainer/VBoxContainer/QuitButton


func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	play_button.grab_focus()


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file(GAMEPLAY_SCENE_PATH)


func _on_quit_pressed() -> void:
	get_tree().quit()
