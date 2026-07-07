class_name Hurtbox
extends Area2D

## An Area2D that receives damage from any Hitbox that overlaps it, and
## reports it via signal - the owner (player, enemy, ...) decides what
## damage actually means. Optionally grants brief invincibility after a
## hit by disabling monitorability, so a stationary hitbox (e.g. a spike
## trap) doesn't deal damage every physics frame while overlapped.

signal damaged(amount: int, hitbox: Hitbox)

@export var invincibility_duration: float = 0.0

## The body (player/enemy) this hurtbox belongs to, set by the owner in
## its _ready(). Lets a Hitbox with the same source skip damaging it -
## see Hitbox._is_same_source.
var source: Node

var invincible: bool = false


func take_hit(amount: int, hitbox: Hitbox) -> void:
	if invincible:
		return
	damaged.emit(amount, hitbox)
	if invincibility_duration > 0.0:
		_start_invincibility()


func _start_invincibility() -> void:
	invincible = true
	set_deferred("monitorable", false)
	await get_tree().create_timer(invincibility_duration).timeout
	invincible = false
	set_deferred("monitorable", true)
