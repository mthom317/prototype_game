extends CharacterBody2D

enum Facing { DOWN, UP, SIDE }

@export var speed: float = 120.0

var facing: Facing = Facing.DOWN

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


func _physics_process(_delta: float) -> void:
	var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_vector * speed
	move_and_slide()
	_update_animation(input_vector)


func _update_animation(input_vector: Vector2) -> void:
	if input_vector == Vector2.ZERO:
		animated_sprite.play("idle_" + _facing_suffix())
		return

	if input_vector.x != 0:
		facing = Facing.SIDE
		animated_sprite.flip_h = input_vector.x < 0
	elif input_vector.y < 0:
		facing = Facing.UP
	else:
		facing = Facing.DOWN

	animated_sprite.play("move_" + _facing_suffix())


func _facing_suffix() -> String:
	match facing:
		Facing.UP:
			return "up"
		Facing.SIDE:
			return "side"
		_:
			return "down"
