class_name Hitbox
extends Area2D

## An Area2D that deals damage to any Hurtbox it overlaps. Knows nothing
## about who owns it or what it hits - reusable for player attacks, enemy
## attacks, or environmental hazards.

signal hit_landed(hurtbox: Hurtbox)

@export var damage: int = 1


func _ready() -> void:
	area_entered.connect(_on_area_entered)


func _on_area_entered(area: Area2D) -> void:
	if area is Hurtbox:
		area.take_hit(damage, self)
		hit_landed.emit(area)
