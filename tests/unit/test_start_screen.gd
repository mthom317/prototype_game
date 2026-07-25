extends GutTest

var start_screen: Control


func before_each() -> void:
	var scene: PackedScene = load("res://scenes/ui/StartScreen.tscn")
	start_screen = add_child_autofree(scene.instantiate())


func test_gameplay_scene_path_resolves() -> void:
	assert_true(ResourceLoader.exists(start_screen.GAMEPLAY_SCENE_PATH))


func test_play_button_connected_to_handler() -> void:
	assert_true(start_screen.play_button.pressed.is_connected(start_screen._on_play_pressed))


func test_quit_button_connected_to_handler() -> void:
	assert_true(start_screen.quit_button.pressed.is_connected(start_screen._on_quit_pressed))
