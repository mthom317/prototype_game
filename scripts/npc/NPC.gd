class_name NPC
extends StaticBody2D

## Stationary hub-area NPC: shows a floating interact prompt when the
## player is nearby and opens a placeholder DialogBox on "interact".
## No movement/routing logic on purpose (see issue #37) - that's a
## follow-up once the real dialogue system exists. The dialog text here
## is a hardcoded placeholder line per NPC, not real dialogue data.

@export var npc_name: String = "Villager"
@export var dialog_text: String = "Hello, traveler! Fine weather we're having."
@export var sprite_frames: SpriteFrames

var _player_in_range: bool = false
var _dialog_open: bool = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var interaction_area: Area2D = $InteractionArea
@onready var prompt_label: Label = $PromptLabel
@onready var dialog_box: DialogBox = $DialogBox


func _ready() -> void:
	if sprite_frames != null:
		animated_sprite.sprite_frames = sprite_frames
		animated_sprite.play("idle_down")
	interaction_area.body_entered.connect(_on_body_entered)
	interaction_area.body_exited.connect(_on_body_exited)
	prompt_label.visible = _should_show_prompt(_player_in_range, _dialog_open)


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("interact"):
		return
	if not _player_in_range:
		return
	_dialog_open = _toggle_dialog(_dialog_open)
	_apply_dialog_state()


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	_player_in_range = true
	prompt_label.visible = _should_show_prompt(_player_in_range, _dialog_open)


func _on_body_exited(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	_player_in_range = false
	_dialog_open = false
	prompt_label.visible = _should_show_prompt(_player_in_range, _dialog_open)
	_apply_dialog_state()


func _apply_dialog_state() -> void:
	if _dialog_open:
		dialog_box.open(npc_name, dialog_text)
	else:
		dialog_box.close()
	prompt_label.visible = _should_show_prompt(_player_in_range, _dialog_open)


## Pure: the prompt only shows while the player is in range and the
## dialog isn't already open (no point prompting "E" over an open box).
func _should_show_prompt(player_in_range: bool, dialog_open: bool) -> bool:
	return player_in_range and not dialog_open


## Pure: interact toggles the dialog open/closed; kept separate from the
## input-event plumbing so it's directly unit-testable.
func _toggle_dialog(is_open: bool) -> bool:
	return not is_open
