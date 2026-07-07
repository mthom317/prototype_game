extends GutTest

var npc: NPC


func before_each() -> void:
	var scene: PackedScene = load("res://scenes/npc/Villager.tscn")
	npc = add_child_autofree(scene.instantiate())


func test_prompt_hidden_when_player_not_in_range() -> void:
	assert_false(npc._should_show_prompt(false, false))


func test_prompt_shown_when_player_in_range_and_dialog_closed() -> void:
	assert_true(npc._should_show_prompt(true, false))


func test_prompt_hidden_when_dialog_open_even_if_in_range() -> void:
	assert_false(npc._should_show_prompt(true, true))


func test_prompt_hidden_when_out_of_range_and_dialog_open() -> void:
	assert_false(npc._should_show_prompt(false, true))


func test_toggle_dialog_opens_when_closed() -> void:
	assert_true(npc._toggle_dialog(false))


func test_toggle_dialog_closes_when_open() -> void:
	assert_false(npc._toggle_dialog(true))


func test_player_entering_range_sets_flag_and_shows_prompt() -> void:
	npc._on_body_entered(_fake_player())
	assert_true(npc._player_in_range)
	assert_true(npc.prompt_label.visible)


func test_player_exiting_range_clears_flag_and_hides_prompt() -> void:
	npc._on_body_entered(_fake_player())
	npc._on_body_exited(_fake_player())
	assert_false(npc._player_in_range)
	assert_false(npc.prompt_label.visible)


func test_player_exiting_range_closes_open_dialog() -> void:
	npc._on_body_entered(_fake_player())
	npc._dialog_open = true
	npc._on_body_exited(_fake_player())
	assert_false(npc._dialog_open)


func test_non_player_body_entering_is_ignored() -> void:
	var body: Node2D = autofree(Node2D.new())
	npc._on_body_entered(body)
	assert_false(npc._player_in_range)


func _fake_player() -> Node2D:
	var body: CharacterBody2D = autofree(CharacterBody2D.new())
	body.add_to_group("player")
	return body
