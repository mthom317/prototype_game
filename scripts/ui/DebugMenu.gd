extends CanvasLayer

## Toggleable (V key) playtesting menu: pick a category (Enemy/NPC/Item),
## then pick a specific scene to spawn next to the player. Works in any
## scene since it's an autoload and spawns into get_tree().current_scene.

const CATALOG: Dictionary = {
	"Enemy":
	{
		"Bear": "res://scenes/enemies/EnemyBear.tscn",
		"Mushroom": "res://scenes/enemies/EnemyMushroom.tscn",
		"Skull": "res://scenes/enemies/EnemySkull.tscn",
		"Slime": "res://scenes/enemies/EnemySlime.tscn",
		"Snake": "res://scenes/enemies/EnemySnake.tscn",
	},
	"NPC":
	{
		"Old Man": "res://scenes/npc/OldMan.tscn",
		"Villager": "res://scenes/npc/Villager.tscn",
	},
	"Item":
	{
		"Healing Potion": "res://scenes/items/HealingPotion.tscn",
	},
}

const SPAWN_OFFSET := Vector2(24, 0)

var _category: String = ""

@onready var panel: Panel = $Panel
@onready var option_list: VBoxContainer = $Panel/MarginContainer/ScrollContainer/VBoxContainer


func _ready() -> void:
	panel.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_debug_menu"):
		_toggle()


func _toggle() -> void:
	panel.visible = not panel.visible
	if panel.visible:
		_category = ""
		_show_categories()


func _show_categories() -> void:
	_clear_options()
	for category_name in CATALOG.keys():
		_add_option_button(category_name, _on_category_selected.bind(category_name))


func _on_category_selected(category_name: String) -> void:
	_category = category_name
	_show_items()


func _show_items() -> void:
	_clear_options()
	_add_option_button("< Back", _show_categories)
	for item_name in CATALOG[_category].keys():
		_add_option_button(item_name, _on_item_selected.bind(CATALOG[_category][item_name]))


func _on_item_selected(scene_path: String) -> void:
	_spawn(scene_path)
	panel.visible = false


func _spawn(scene_path: String) -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player == null:
		return
	var instance: Node2D = load(scene_path).instantiate()
	instance.global_position = player.global_position + SPAWN_OFFSET
	get_tree().current_scene.add_child(instance)


func _clear_options() -> void:
	for child in option_list.get_children():
		child.queue_free()


func _add_option_button(label: String, callback: Callable) -> void:
	var button := Button.new()
	button.text = label
	button.pressed.connect(callback)
	option_list.add_child(button)
