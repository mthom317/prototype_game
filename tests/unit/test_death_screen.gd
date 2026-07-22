extends GutTest

var death_screen: CanvasLayer


func before_each() -> void:
	var scene: PackedScene = load("res://scenes/ui/DeathScreen.tscn")
	death_screen = add_child_autofree(scene.instantiate())


func test_overlay_hidden_by_default() -> void:
	assert_false(death_screen.overlay.visible)


func test_stays_processing_while_tree_paused() -> void:
	assert_eq(death_screen.process_mode, Node.PROCESS_MODE_ALWAYS)


func test_restart_button_connected_to_handler() -> void:
	assert_true(death_screen.restart_button.pressed.is_connected(death_screen._on_restart_pressed))


func test_quit_button_connected_to_handler() -> void:
	assert_true(death_screen.quit_button.pressed.is_connected(death_screen._on_quit_pressed))
