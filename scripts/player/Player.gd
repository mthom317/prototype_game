extends CharacterBody2D

enum Facing { DOWN, UP, SIDE }

const ATTACK_DURATION := 0.3
const ATTACK_COOLDOWN := 0.15
const ATTACK_HITBOX_OFFSET := 12.0

@export var speed: float = 120.0

var facing: Facing = Facing.DOWN
var is_attacking: bool = false
var can_attack: bool = true
var potion_count: int = 0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health: Health = $Health
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var hitbox: Hitbox = $Hitbox


func _ready() -> void:
	add_to_group("player")
	hurtbox.damaged.connect(_on_hurtbox_damaged)
	hitbox.monitoring = false


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("attack") and can_attack and not is_attacking:
		_start_attack()

	if Input.is_action_just_pressed("use_item"):
		_use_item()

	if is_attacking:
		velocity = Vector2.ZERO
	else:
		var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
		velocity = input_vector * speed
		_update_animation(input_vector)

	move_and_slide()


func _start_attack() -> void:
	is_attacking = true
	can_attack = false
	animated_sprite.play("attack_" + _facing_suffix())
	_position_hitbox()
	hitbox.monitoring = true

	await get_tree().create_timer(ATTACK_DURATION).timeout
	hitbox.monitoring = false
	is_attacking = false

	await get_tree().create_timer(ATTACK_COOLDOWN).timeout
	can_attack = true


func _position_hitbox() -> void:
	match facing:
		Facing.UP:
			hitbox.position = Vector2(0, -ATTACK_HITBOX_OFFSET)
		Facing.SIDE:
			var direction := -1.0 if animated_sprite.flip_h else 1.0
			hitbox.position = Vector2(direction * ATTACK_HITBOX_OFFSET, 0)
		_:
			hitbox.position = Vector2(0, ATTACK_HITBOX_OFFSET)


func pick_up_potion() -> void:
	potion_count += 1


func _use_item() -> void:
	if not _should_consume_potion(potion_count):
		return
	potion_count -= 1
	# Placeholder heal amount: fills all hearts regardless of how much was
	# missing. Tune to a fixed restore amount once the design settles.
	health.heal(health.max_health)


## Pure decision kept separate from node state so it's directly
## unit-testable: consuming requires at least one potion in reserve.
func _should_consume_potion(count: int) -> bool:
	return count > 0


func _on_hurtbox_damaged(amount: int, _hitbox: Hitbox) -> void:
	health.apply_damage(amount)
	_flash_invincibility()


func _flash_invincibility() -> void:
	var loops: int = maxi(1, int(hurtbox.invincibility_duration / 0.2))
	var tween := create_tween()
	tween.set_loops(loops)
	tween.tween_property(animated_sprite, "modulate:a", 0.3, 0.1)
	tween.tween_property(animated_sprite, "modulate:a", 1.0, 0.1)


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
