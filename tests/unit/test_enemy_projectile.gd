extends GutTest

const PROJECTILE_SCENE: PackedScene = preload("res://scenes/enemies/EnemyProjectile.tscn")

var projectile: EnemyProjectile


func before_each() -> void:
	projectile = add_child_autofree(PROJECTILE_SCENE.instantiate())


func test_physics_process_moves_along_direction_scaled_by_speed_and_delta() -> void:
	projectile.direction = Vector2.RIGHT
	projectile.speed = 100.0
	projectile.position = Vector2.ZERO
	projectile._physics_process(0.5)
	assert_eq(projectile.position, Vector2(50, 0))


func test_physics_process_moves_along_arbitrary_direction() -> void:
	projectile.direction = Vector2(0, -1)
	projectile.speed = 40.0
	projectile.position = Vector2(10, 10)
	projectile._physics_process(1.0)
	assert_eq(projectile.position, Vector2(10, -30))


func test_on_hit_landed_frees_the_projectile() -> void:
	projectile._on_hit_landed(autofree(Hurtbox.new()))
	assert_true(not is_instance_valid(projectile) or projectile.is_queued_for_deletion())


func test_on_body_entered_frees_the_projectile() -> void:
	projectile._on_body_entered(autofree(StaticBody2D.new()))
	assert_true(not is_instance_valid(projectile) or projectile.is_queued_for_deletion())


func test_despawns_after_lifetime_elapses() -> void:
	# _ready() (and its lifetime timer) only runs once the node enters the
	# tree, so set the shortened lifetime before adding this second
	# instance rather than mutating the one from before_each().
	var short_lived: EnemyProjectile = PROJECTILE_SCENE.instantiate()
	short_lived.lifetime = 0.1
	add_child_autofree(short_lived)

	await wait_seconds(0.2)
	assert_true(not is_instance_valid(short_lived) or short_lived.is_queued_for_deletion())
