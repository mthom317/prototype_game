extends GutTest

## DebugMenu is registered as a global autoload (see project.godot
## [autoload]), so it's already present in the tree under this name -
## no need to instantiate it here.


func test_catalog_scene_paths_all_resolve() -> void:
	var checked_any := false
	for category_name in DebugMenu.CATALOG.keys():
		var category: Dictionary = DebugMenu.CATALOG[category_name]
		for item_name in category.keys():
			var scene_path: String = category[item_name]
			checked_any = true
			assert_true(
				ResourceLoader.exists(scene_path),
				"%s > %s scene path does not resolve: %s" % [category_name, item_name, scene_path]
			)
	assert_true(checked_any, "expected DebugMenu.CATALOG to contain at least one entry")
