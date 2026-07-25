extends CharacterBody2D

enum Facing { DOWN, UP, SIDE }

const ATTACK_DURATION := 0.3
const ATTACK_COOLDOWN := 0.15
const ATTACK_HITBOX_OFFSET := 12.0
const ICE_STEER_FACTOR := 0.06

## Hold-vs-tap threshold: releasing "attack" before this many seconds have
## elapsed is a combo tap; at/after this it's a charged hit.
const CHARGE_THRESHOLD := 0.35
## How long after a combo hit's active window closes a follow-up tap still
## chains the combo, rather than starting a fresh one.
const COMBO_WINDOW := 0.35
const CHARGE_ATTACK_DURATION := 0.4
const COMBO_HIT_DAMAGE := 1
const COMBO_FINISHER_DAMAGE := 2
const CHARGED_DAMAGE := 3
const COMBO_FINISHER_HITBOX_SCALE := 1.2
const CHARGED_HITBOX_SCALE := 1.6
const CHARGE_TELEGRAPH_COLOR := Color(1.4, 1.4, 0.6)

@export var speed: float = 120.0

var facing: Facing = Facing.DOWN
var is_attacking: bool = false
var can_attack: bool = true
var combo_step: int = 0
var is_charging: bool = false
var potion_count: int = 0
var has_boots: bool = false
var _on_ice: bool = false
var _charge_start_msec: int = 0
var _charge_tween: Tween

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health: Health = $Health
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var hitbox: Hitbox = $Hitbox


func _ready() -> void:
	add_to_group("player")
	hurtbox.damaged.connect(_on_hurtbox_damaged)
	health.died.connect(_on_died)
	hitbox.monitoring = false
	hitbox.source = self
	hurtbox.source = self


func _physics_process(_delta: float) -> void:
	if (
		Input.is_action_just_pressed("attack")
		and can_attack
		and not is_attacking
		and not is_charging
	):
		_begin_charge()
	elif is_charging and Input.is_action_just_released("attack"):
		_release_charge()

	if Input.is_action_just_pressed("use_item"):
		_use_item()

	if is_attacking or is_charging:
		velocity = Vector2.ZERO
	else:
		var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
		velocity = _compute_movement_velocity(velocity, input_vector, speed, _on_ice and has_boots)
		_update_animation(input_vector)

	move_and_slide()


func _begin_charge() -> void:
	is_charging = true
	can_attack = false
	_charge_start_msec = Time.get_ticks_msec()
	_start_charge_telegraph()


func _release_charge() -> void:
	var held_seconds := (Time.get_ticks_msec() - _charge_start_msec) / 1000.0
	is_charging = false
	_stop_charge_telegraph()

	if _is_charged_hold(held_seconds):
		_perform_charged_hit()
	else:
		_perform_combo_hit()


func _start_charge_telegraph() -> void:
	_charge_tween = create_tween()
	_charge_tween.set_loops()
	_charge_tween.tween_property(animated_sprite, "modulate", CHARGE_TELEGRAPH_COLOR, 0.15)
	_charge_tween.tween_property(animated_sprite, "modulate", Color.WHITE, 0.15)


func _stop_charge_telegraph() -> void:
	if _charge_tween:
		_charge_tween.kill()
	animated_sprite.modulate = Color.WHITE


## Pure: whether a hold this long counts as a charged hit rather than a tap.
func _is_charged_hold(held_seconds: float) -> bool:
	return held_seconds >= CHARGE_THRESHOLD


## Pure: damage dealt by the combo hit at the given step (0/1 = base, 2 = finisher).
func _combo_hit_damage(step: int) -> int:
	return COMBO_FINISHER_DAMAGE if step == 2 else COMBO_HIT_DAMAGE


## Pure: hitbox scale for the combo hit at the given step.
func _combo_hit_scale(step: int) -> float:
	return COMBO_FINISHER_HITBOX_SCALE if step == 2 else 1.0


## Pure: the combo step that follows the given one (2, the finisher, wraps to 0).
func _next_combo_step(step: int) -> int:
	return 0 if step == 2 else step + 1


func _perform_combo_hit() -> void:
	var step := combo_step
	combo_step = _next_combo_step(step)
	_perform_attack_hit(_combo_hit_damage(step), _combo_hit_scale(step), ATTACK_DURATION, 0.0)


func _perform_charged_hit() -> void:
	combo_step = 0
	_perform_attack_hit(
		CHARGED_DAMAGE, CHARGED_HITBOX_SCALE, CHARGE_ATTACK_DURATION, ATTACK_COOLDOWN
	)


func _perform_attack_hit(
	damage: int, hitbox_scale: float, duration: float, recovery_cooldown: float
) -> void:
	is_attacking = true
	can_attack = false
	hitbox.damage = damage
	hitbox.scale = Vector2.ONE * hitbox_scale
	animated_sprite.play("attack_" + _facing_suffix())
	_position_hitbox()
	hitbox.monitoring = true

	await get_tree().create_timer(duration).timeout
	hitbox.monitoring = false
	hitbox.scale = Vector2.ONE
	is_attacking = false

	if recovery_cooldown > 0.0:
		await get_tree().create_timer(recovery_cooldown).timeout
		can_attack = true
		return

	can_attack = true

	var expected_step := combo_step
	await get_tree().create_timer(COMBO_WINDOW).timeout
	if combo_step == expected_step and not is_attacking:
		combo_step = 0


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


func pick_up_boots() -> void:
	has_boots = true


## Called by IcePatch on body_entered/body_exited. No effect on movement
## without boots (see notes/07-design-questions.md section 2 - boots is
## what lets you cross ice at all in v1, not just skate faster).
func set_on_ice(value: bool) -> void:
	_on_ice = value


## Pure: off ice (or without boots), movement snaps directly to input each
## frame, same as always. On ice with boots, there's no friction - zero
## input keeps sliding at the current velocity instead of stopping, and
## nonzero input steers gradually rather than snapping.
func _compute_movement_velocity(
	current_velocity: Vector2, input_vector: Vector2, move_speed: float, is_sliding: bool
) -> Vector2:
	if not is_sliding:
		return input_vector * move_speed
	if input_vector == Vector2.ZERO:
		return current_velocity
	return current_velocity.lerp(input_vector * move_speed, ICE_STEER_FACTOR)


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


func _on_died() -> void:
	DeathScreen.show_game_over()


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
