extends SceneTree

const PET_PREFAB_PATH := "res://Features/Battle/Prefabs/Units/BattleUnit/BattleUnit.tscn"
const FLOATING_UI_SCENE_PATH := "res://Features/ArtistFlow/Views/ArtistFlowView.tscn"
const TEST_TEXTURE_PATH := "res://Features/ArtistFlow/Art/Pets/Sprites/Sprite_WhiteFox.png"


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var prefab := load(PET_PREFAB_PATH) as PackedScene
	if prefab == null:
		_fail("Shared pet prefab could not be loaded.")
		return
	var pet_view := prefab.instantiate() as Control
	root.add_child(pet_view)
	await process_frame

	var script_paths: Array[String] = []
	_collect_script_paths(pet_view, script_paths)
	if script_paths.size() != 3:
		_fail("Shared pet prefab must contain exactly three scripts: %s" % script_paths)
		return

	var texture := load(TEST_TEXTURE_PATH) as Texture2D
	pet_view.call("set_battle_data", {
		"team": "player",
		"hp": 12,
		"attack_damage": 4,
	}, {
		"cell_size": Vector2(120.0, 100.0),
		"sprite_texture": texture,
	})
	if pet_view.call("get_display_mode") != &"battle":
		_fail("Battle mode was not applied.")
		return
	if (pet_view.get_node("HpLabel") as Label).text != "12":
		_fail("Battle HP did not flow through the status component.")
		return

	pet_view.call("set_collection_data", {"quality": "bronze"}, {
		"slot_size": Vector2(220.0, 220.0),
		"sprite_texture": texture,
	})
	if pet_view.call("get_display_mode") != &"collection":
		_fail("Collection mode was not applied.")
		return
	if pet_view.call("get_display_texture") != texture:
		_fail("Collection mode did not keep the supplied pet texture.")
		return
	pet_view.call("reset_pet_view")
	if pet_view.call("get_display_mode") != &"none":
		_fail("Reset left stale pet display state.")
		return

	pet_view.queue_free()
	var fixture_root := Node.new()
	root.add_child(fixture_root)
	current_scene = fixture_root
	var floating_ui := (load(FLOATING_UI_SCENE_PATH) as PackedScene).instantiate()
	fixture_root.add_child(floating_ui)
	await process_frame
	await process_frame
	var party_button := floating_ui.get_node("MainBG/Containers/Party/Party_Container/Party_Slot/PareyButton") as TextureButton
	var bag_button := floating_ui.get_node("MainBG/Containers/Middle/Middle_Bag/Bag_Slot/Bag_Button") as TextureButton
	var shop_button := floating_ui.get_node("MainBG/Containers/Middle/Middle_Shop/Shop_Slot/Shop_Button") as TextureButton
	if party_button.get_node_or_null("SharedPetView") == null:
		_fail("Party pets are not connected to the shared prefab.")
		return
	if bag_button.get_node_or_null("SharedPetView") == null:
		_fail("Bag pets are not connected to the shared prefab.")
		return
	if shop_button.get_node_or_null("SharedPetView") != null:
		_fail("Shop offers must retain their original TextureButton presentation.")
		return
	var middle := floating_ui.get_node("MainBG/Containers/Middle")
	if not middle.call("_set_party_item", 0, texture, &"bronze"):
		_fail("A purchased pet could not enter the party slot.")
		return
	var party_view := party_button.get_node("SharedPetView") as Control
	if party_view.call("get_display_mode") != &"collection" or party_view.call("get_display_texture") != texture:
		_fail("The purchased party pet did not render through collection mode.")
		return
	if not middle.call("_set_bag_item", 0, texture, &"bronze"):
		_fail("A purchased pet could not enter the bag slot.")
		return
	var bag_view := bag_button.get_node("SharedPetView") as Control
	if bag_view.call("get_display_mode") != &"collection" or bag_view.call("get_display_texture") != texture:
		_fail("The purchased bag pet did not render through collection mode.")
		return

	print("SHARED_PET_PREFAB_OK prefab=%s scripts=%d" % [PET_PREFAB_PATH, script_paths.size()])
	current_scene = null
	fixture_root.queue_free()
	await process_frame
	quit()


func _collect_script_paths(node: Node, result: Array[String]) -> void:
	var script := node.get_script() as Script
	if script != null:
		result.append(script.resource_path)
	for child in node.get_children():
		_collect_script_paths(child, result)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
