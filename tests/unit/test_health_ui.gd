extends GutTest

var health_ui: HealthUI


func before_each() -> void:
	var scene: PackedScene = load("res://scenes/ui/HealthUI.tscn")
	health_ui = add_child_autofree(scene.instantiate())


func test_set_health_creates_one_icon_per_heart_rounded_up() -> void:
	health_ui.set_health(12, 12)
	assert_eq(health_ui._heart_icons.size(), 3)


func test_set_health_rounds_up_partial_heart_count() -> void:
	# 13 quarters of max health needs a 4th (partial) heart icon.
	health_ui.set_health(13, 13)
	assert_eq(health_ui._heart_icons.size(), 4)


func test_ensure_icon_count_adds_icons_as_children() -> void:
	health_ui._ensure_icon_count(3)
	assert_eq(health_ui._heart_icons.size(), 3)
	assert_eq(health_ui.get_child_count(), 3)


func test_ensure_icon_count_removes_extra_icons_when_shrinking() -> void:
	health_ui._ensure_icon_count(3)
	health_ui._ensure_icon_count(1)
	assert_eq(health_ui._heart_icons.size(), 1)


func test_set_health_full_hearts_use_full_texture() -> void:
	health_ui.set_health(8, 8)
	for icon in health_ui._heart_icons:
		assert_eq(icon.texture, health_ui._heart_textures[4])


func test_set_health_empty_hearts_use_empty_texture() -> void:
	health_ui.set_health(0, 8)
	for icon in health_ui._heart_icons:
		assert_eq(icon.texture, health_ui._heart_textures[0])


func test_set_health_renders_partial_quarter_heart() -> void:
	# max 8 -> 2 hearts. current=5 leaves the first heart full (4 quarters
	# used) and the second heart at 1 quarter remaining.
	health_ui.set_health(5, 8)
	assert_eq(health_ui._heart_icons[0].texture, health_ui._heart_textures[4])
	assert_eq(health_ui._heart_icons[1].texture, health_ui._heart_textures[1])


func test_set_health_shrinks_icon_count_when_max_health_decreases() -> void:
	health_ui.set_health(12, 12)
	health_ui.set_health(4, 4)
	assert_eq(health_ui._heart_icons.size(), 1)
