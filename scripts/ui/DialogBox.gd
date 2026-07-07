class_name DialogBox
extends CanvasLayer

## Deliberately minimal placeholder dialog box: a panel pinned to the
## bottom of the screen showing a speaker name and a single line of text.
## This will be replaced by the real text-box/portrait dialogue system in
## a follow-up (see issue #37) - no typewriter effect, no multi-line
## advancing, no portraits here on purpose.

@onready var name_label: Label = $Panel/MarginContainer/VBoxContainer/NameLabel
@onready var text_label: Label = $Panel/MarginContainer/VBoxContainer/TextLabel


func _ready() -> void:
	hide()


func open(speaker_name: String, text: String) -> void:
	name_label.text = speaker_name
	text_label.text = text
	show()


func close() -> void:
	hide()


## Pure: given the current visibility state, returns whether opening
## should be a no-op (already open) - kept as a helper so the open/close
## decision is unit-testable without a live CanvasLayer.
func _should_open(is_open: bool) -> bool:
	return not is_open
