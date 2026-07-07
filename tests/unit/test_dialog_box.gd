extends GutTest

var dialog_box: DialogBox


func before_each() -> void:
	var scene: PackedScene = load("res://scenes/ui/DialogBox.tscn")
	dialog_box = add_child_autofree(scene.instantiate())


func test_starts_hidden() -> void:
	assert_false(dialog_box.visible)


func test_open_shows_the_box_with_speaker_and_text() -> void:
	dialog_box.open("Old Man", "Hello, traveler!")
	assert_true(dialog_box.visible)
	assert_eq(dialog_box.name_label.text, "Old Man")
	assert_eq(dialog_box.text_label.text, "Hello, traveler!")


func test_close_hides_the_box() -> void:
	dialog_box.open("Old Man", "Hello, traveler!")
	dialog_box.close()
	assert_false(dialog_box.visible)


func test_open_again_with_different_text_updates_labels() -> void:
	dialog_box.open("Old Man", "Hello, traveler!")
	dialog_box.open("Villager", "Nice day, isn't it?")
	assert_true(dialog_box.visible)
	assert_eq(dialog_box.name_label.text, "Villager")
	assert_eq(dialog_box.text_label.text, "Nice day, isn't it?")
