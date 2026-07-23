extends SceneTree

const ARTIST_FLOW_SCENE := "res://Features/ArtistFlow/Views/ArtistFlowView.tscn"
const BATTLE_SCENE := "res://Features/Battle/Views/BattleMainView.tscn"

const ARTIST_FLOW_COMPONENTS := {
	"MainBG/GoldCounter": "res://Shared/Prefabs/HUD/GoldCounter/GoldCounterView.tscn",
	"MainBG/Containers/Bags": "res://Features/ArtistFlow/Prefabs/Inventory/BagLauncherView.tscn",
	"MainBG/Containers/Party": "res://Features/ArtistFlow/Prefabs/Party/PartyBarView.tscn",
	"MainBG/Containers/Middle/Middle_Three_Option": "res://Features/ArtistFlow/Prefabs/Route/RouteOptionsPanelView.tscn",
	"MainBG/Containers/Middle/Middle_Shop": "res://Features/ArtistFlow/Prefabs/Shop/ShopPanelView.tscn",
	"MainBG/Containers/Middle/Middle_Bag": "res://Features/ArtistFlow/Prefabs/Inventory/InventoryPanelView.tscn",
	"MainBG/Containers/Top": "res://Features/ArtistFlow/Prefabs/Navigation/TopActionBarView.tscn",
}

const BATTLE_COMPONENTS := {
	"GoldCounter": "res://Shared/Prefabs/HUD/GoldCounter/GoldCounterView.tscn",
	"BoardGrid": "res://Features/Battle/Prefabs/Board/BattleBoardPanel.tscn",
	"ActionPanel": "res://Features/Battle/Prefabs/HUD/BattleActionPanel/BattleActionPanelView.tscn",
}


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	if not await _assert_scene_components(ARTIST_FLOW_SCENE, ARTIST_FLOW_COMPONENTS):
		return
	await create_timer(0.7).timeout
	var artist_controller := current_scene.get_node("MainBG/Containers/Middle")
	if bool(artist_controller.get("_is_transitioning")):
		_fail("ArtistFlow initial transition never releases input")
		return
	if not await _assert_scene_components(BATTLE_SCENE, BATTLE_COMPONENTS):
		return
	await create_timer(1.8).timeout
	var board := current_scene.get_node("BoardGrid")
	var action_panel := current_scene.get_node("ActionPanel")
	if board.get("_auto_arrange_button") != action_panel.call("get_auto_arrange_button"):
		_fail("Battle board did not bind the scripted action panel after ready")
		return
	if board.get("_begin_turn_button") != action_panel.call("get_begin_turn_button"):
		_fail("Battle board did not bind the begin-turn input after ready")
		return
	print("Composite scripted prefab boundary smoke test passed.")
	await _cleanup_current_scene()
	quit()


func _assert_scene_components(scene_path: String, components: Dictionary) -> bool:
	var error := change_scene_to_file(scene_path)
	if error != OK:
		_fail("Unable to load page scene: %s" % scene_path)
		return false
	await process_frame
	await process_frame
	var page := current_scene
	for node_path in components:
		var component := page.get_node_or_null(NodePath(node_path))
		if component == null:
			_fail("Missing component instance: %s/%s" % [scene_path, node_path])
			return false
		if component.scene_file_path != components[node_path]:
			_fail("Component is embedded instead of instanced: %s" % node_path)
			return false
		if not component.has_method("setup") or not component.has_method("refresh"):
			_fail("Component has no public presentation API: %s" % node_path)
			return false
	return true


func _fail(message: String) -> void:
	push_error(message)
	await _cleanup_current_scene()
	quit(1)


func _cleanup_current_scene() -> void:
	var scene := current_scene
	current_scene = null
	if is_instance_valid(scene):
		scene.free()
	await process_frame
	await process_frame
