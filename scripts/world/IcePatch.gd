class_name IcePatch
extends Area2D

## A frictionless zone. Tells the player (via set_on_ice) whether they're
## standing on it; the player decides what that means (only boots owners
## actually slide - see Player._compute_movement_velocity).


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("set_on_ice"):
		body.set_on_ice(true)


func _on_body_exited(body: Node2D) -> void:
	if body.has_method("set_on_ice"):
		body.set_on_ice(false)
