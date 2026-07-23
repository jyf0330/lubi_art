extends SceneTree

const LOCATIONS := {
	"res://Features/MainMenu/Views/MainMenuView.tscn": {
		"scene": "res://Scenes/MainMenu/MainMenuScene.tscn",
		"minimum_prefabs": 1,
	},
	"res://Features/ArtistFlow/Views/ArtistFlowView.tscn": {
		"scene": "res://Scenes/ArtistFlow/ArtistFlowScene.tscn",
		"minimum_prefabs": 7,
	},
	"res://Features/Battle/Views/BattleMainView.tscn": {
		"scene": "res://Scenes/Battle/BattleScene.tscn",
		"minimum_prefabs": 3,
	},
}


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	for view_path in LOCATIONS:
		var contract: Dictionary = LOCATIONS[view_path]
		if not _assert_location(view_path, contract):
			return

	print("LOCATION_SCENE_PREFAB_SYNC_OK locations=%d" % LOCATIONS.size())
	quit()


func _assert_location(view_path: String, contract: Dictionary) -> bool:
	var scene_path := String(contract["scene"])
	var view_source := _read_source(view_path)
	if not view_source.contains(scene_path):
		_fail("Stable View does not point to its root location scene: %s" % view_path)
		return false
	var view_root_section := view_source.substr(view_source.find("[node ")).strip_edges()
	if view_source.count("[node ") != 1 or view_root_section.split("\n").size() != 1:
		_fail("Stable View duplicates or overrides the location scene: %s" % view_path)
		return false

	var scene_source := _read_source(scene_path)
	var prefab_ids := _collect_prefab_resource_ids(scene_source)
	if prefab_ids.size() < int(contract["minimum_prefabs"]):
		_fail("Location scene is not assembled from enough prefabs: %s" % scene_path)
		return false
	if _has_prefab_child_overrides(scene_source, prefab_ids):
		_fail("Location scene stores internal prefab child overrides: %s" % scene_path)
		return false

	var view_packed := load(view_path) as PackedScene
	var location_packed := load(scene_path) as PackedScene
	if view_packed == null or location_packed == null:
		_fail("View/location scene cannot be loaded: %s" % scene_path)
		return false
	var view := view_packed.instantiate()
	var location := location_packed.instantiate()
	var matches: bool = view.get_class() == location.get_class() \
		and view.get_script() == location.get_script() \
		and _child_signature(view) == _child_signature(location)
	view.free()
	location.free()
	if not matches:
		_fail("Stable View drifted from its root location scene: %s" % view_path)
		return false
	return true


func _collect_prefab_resource_ids(source: String) -> Dictionary:
	var ids := {}
	var regex := RegEx.new()
	regex.compile("\\[ext_resource type=\"PackedScene\" path=\"[^\"]*/Prefabs/[^\"]+\" id=\"([^\"]+)\"\\]")
	for match in regex.search_all(source):
		ids[match.get_string(1)] = true
	return ids


func _has_prefab_child_overrides(source: String, prefab_ids: Dictionary) -> bool:
	var node_regex := RegEx.new()
	node_regex.compile("\\[node name=\"([^\"]+)\"(?: parent=\"([^\"]*)\")? instance=ExtResource\\(\"([^\"]+)\"\\)\\]")
	for match in node_regex.search_all(source):
		if not prefab_ids.has(match.get_string(3)):
			continue
		var parent_path := match.get_string(2)
		var instance_path := match.get_string(1) if parent_path.is_empty() else "%s/%s" % [parent_path, match.get_string(1)]
		if source.contains("parent=\"%s" % instance_path):
			return true
	return false


func _child_signature(node: Node) -> Array:
	var signature := []
	for child in node.get_children():
		signature.append({
			"name": String(child.name),
			"class": child.get_class(),
			"script": child.get_script().resource_path if child.get_script() != null else "",
			"children": _child_signature(child),
		})
	return signature


func _read_source(path: String) -> String:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return ""
	return file.get_as_text()


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
