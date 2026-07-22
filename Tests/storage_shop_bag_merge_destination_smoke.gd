extends SceneTree

const START_SCENE := "res://Scenes/start_scene.tscn"
const FLOATING_UI_SCENE := "res://FloatingUI/Scenes/UI.tscn"
const WHITE_FOX_TEXTURE := "res://FloatingUI/SpriteImages/Sprite_WhiteFox.png"
const ACTIVE_GAME_SESSION_META := &"active_game_session"
const PARTY := &"party"
const BAG := &"bag"
const BRONZE := &"bronze"
const SILVER := &"silver"
const DIAMOND := &"diamond"


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	if has_meta(ACTIVE_GAME_SESSION_META):
		remove_meta(ACTIVE_GAME_SESSION_META)

	var start_scene := (load(START_SCENE) as PackedScene).instantiate()
	root.add_child(start_scene)
	current_scene = start_scene
	await process_frame
	start_scene.get_node("StartGameButton").button_pressed.emit()
	await process_frame
	await process_frame
	if current_scene == null or current_scene.scene_file_path != FLOATING_UI_SCENE:
		_fail("The test could not enter the floating UI scene.")
		return

	var middle := current_scene.get_node("MainBG/Containers/Middle")
	# Keep this focused on destination rules; animation lifecycle is covered by
	# merge_animation_smoke.gd.
	middle.set("_merge_animations_enabled", false)
	var fox := load(WHITE_FOX_TEXTURE) as Texture2D
	if fox == null:
		_fail("White fox test texture could not be loaded.")
		return

	# A shop card dropped onto a matching bag card upgrades in the bag first,
	# then moves the finished result into the first empty party slot.
	middle.call("_set_storage_item", BAG, 0, fox, BRONZE)
	if not middle.call("_receive_shop_item_in_storage", BAG, 0, fox, BRONZE):
		_fail("The shop card was not accepted by the matching bag slot.")
		return
	if not _is_card_at(middle, PARTY, 0, SILVER):
		_fail("The upgraded shop card did not move from the bag into the party.")
		return
	if _get_items(middle, BAG)[0] != null:
		_fail("The bag kept a duplicate after moving the upgraded result to the party.")
		return

	# The same preference applies when the shop card first lands in an empty bag
	# slot and auto-merges with a matching card already in the party.
	middle.call("_clear_storage_item", PARTY, 0)
	middle.call("_set_storage_item", PARTY, 0, fox, BRONZE)
	if not middle.call("_receive_shop_item_in_storage", BAG, 0, fox, BRONZE):
		_fail("The shop card was not accepted by the empty bag slot.")
		return
	if not _is_card_at(middle, PARTY, 0, SILVER):
		_fail("A cross-storage auto-merge did not return its result to the party.")
		return

	# If every party slot is occupied, the upgraded result must remain in the bag.
	middle.call("_clear_storage_item", PARTY, 0)
	var party_items := _get_items(middle, PARTY)
	for index in party_items.size():
		middle.call("_set_storage_item", PARTY, index, fox, DIAMOND)
	middle.call("_set_storage_item", BAG, 0, fox, BRONZE)
	if not middle.call("_receive_shop_item_in_storage", BAG, 0, fox, BRONZE):
		_fail("The shop card was not accepted while the party was full.")
		return
	if not _is_card_at(middle, BAG, 0, SILVER):
		_fail("The upgraded result did not stay in the bag when the party was full.")
		return

	print("Storage shop-to-bag merge destination smoke test passed.")
	var scene_to_free := current_scene
	current_scene = null
	scene_to_free.queue_free()
	await process_frame
	quit()


func _get_items(middle: Node, source: StringName) -> Array:
	return middle.get("_party_items" if source == PARTY else "_bag_items")


func _is_card_at(middle: Node, source: StringName, index: int, quality: StringName) -> bool:
	var items := _get_items(middle, source)
	var qualities: Array = middle.get("_party_item_qualities" if source == PARTY else "_bag_item_qualities")
	return items[index] != null and qualities[index] == quality


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
