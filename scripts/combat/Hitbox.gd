class_name Hitbox
extends Area2D

## An Area2D that deals damage to any Hurtbox it overlaps. Knows nothing
## about who owns it or what it hits - reusable for player attacks, enemy
## attacks, or environmental hazards.

signal hit_landed(hurtbox: Hurtbox)

@export var damage: int = 1

## The body (player/enemy) this hitbox attacks on behalf of, set by the
## owner in its _ready(). A Hurtbox reporting the same source is skipped -
## characters don't damage themselves with their own hitbox (e.g. a
## player's sword hitbox overlapping their own hurtbox on a downward
## swing, or an enemy's contact-damage hitbox coinciding with its own
## hurtbox).
var source: Node


func _ready() -> void:
	area_entered.connect(_on_area_entered)


func _on_area_entered(area: Area2D) -> void:
	if area is Hurtbox and not _is_same_source(area):
		area.take_hit(damage, self)
		hit_landed.emit(area)


## Pure: whether the given hurtbox belongs to the same owner as this hitbox.
func _is_same_source(hurtbox: Hurtbox) -> bool:
	return source != null and hurtbox.source == source
