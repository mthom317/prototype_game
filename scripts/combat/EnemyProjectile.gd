class_name EnemyProjectile
extends Area2D

## Small projectile fired by ranged enemies (e.g. EnemyMushroom). Travels in
## a straight line at `speed` along `direction`, deals damage to whatever
## Hurtbox it overlaps via an owned Hitbox, and frees itself on hit, on
## hitting the world, or after `lifetime` seconds - whichever comes first.
## Physics layer 8 ("projectile"); the Hitbox child (layer 4, mask 5) does
## the actual damage-dealing, this node's own mask (layer 1, "world")
## detects walls so the projectile doesn't fly through them forever.

@export var speed: float = 140.0
@export var lifetime: float = 3.0

var direction: Vector2 = Vector2.RIGHT

@onready var hitbox: Hitbox = $Hitbox


func _ready() -> void:
	hitbox.hit_landed.connect(_on_hit_landed)
	body_entered.connect(_on_body_entered)
	var timer := get_tree().create_timer(lifetime)
	timer.timeout.connect(queue_free)


func _physics_process(delta: float) -> void:
	position += direction * speed * delta


func _on_hit_landed(_hurtbox: Hurtbox) -> void:
	queue_free()


func _on_body_entered(_body: Node2D) -> void:
	queue_free()
