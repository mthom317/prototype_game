class_name HealthUI
extends Control

## Renders a row of hearts from a 5-frame quarter-heart spritesheet
## (empty, quarter, half, three-quarter, full), sized to whatever
## current/max health it's told about - doesn't know about Health,
## Hurtbox, or who owns it.

const HEART_SIZE := 16
const HEART_SPACING := 2
const QUARTERS_PER_HEART := 4

@export var heart_sheet: Texture2D

var _heart_textures: Array[AtlasTexture] = []
var _heart_icons: Array[TextureRect] = []


func _ready() -> void:
	for i in range(QUARTERS_PER_HEART + 1):
		var atlas := AtlasTexture.new()
		atlas.atlas = heart_sheet
		atlas.region = Rect2(i * HEART_SIZE, 0, HEART_SIZE, HEART_SIZE)
		_heart_textures.append(atlas)


func set_health(current: int, max_health: int) -> void:
	var heart_count := int(ceil(float(max_health) / QUARTERS_PER_HEART))
	_ensure_icon_count(heart_count)
	for i in range(heart_count):
		var remaining: int = clamp(current - i * QUARTERS_PER_HEART, 0, QUARTERS_PER_HEART)
		_heart_icons[i].texture = _heart_textures[remaining]


func _ensure_icon_count(count: int) -> void:
	while _heart_icons.size() < count:
		var icon := TextureRect.new()
		icon.custom_minimum_size = Vector2(HEART_SIZE, HEART_SIZE)
		icon.position = Vector2(_heart_icons.size() * (HEART_SIZE + HEART_SPACING), 0)
		add_child(icon)
		_heart_icons.append(icon)
	while _heart_icons.size() > count:
		var icon: TextureRect = _heart_icons.pop_back()
		icon.queue_free()
