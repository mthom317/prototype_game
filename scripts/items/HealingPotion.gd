class_name HealingPotion
extends Area2D

## A world pickup on the "item" physics layer. Sits idle until the player's
## body overlaps it, then increments the player's potion_count and removes
## itself. Doesn't know anything about healing - that's decided later, when
## the player consumes the potion via the use_item action.


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("pick_up_potion"):
		body.pick_up_potion()
		queue_free()
