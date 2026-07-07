class_name Boots
extends Area2D

## A world pickup on the "item" physics layer. Sits idle until the player's
## body overlaps it, then sets the player's has_boots flag and removes
## itself.


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("pick_up_boots"):
		body.pick_up_boots()
		queue_free()
