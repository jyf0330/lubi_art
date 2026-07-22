extends SceneTree

const FLOATING_UI_SCENE := "res://Features/ArtistFlow/Views/ArtistFlowView.tscn"
const WHITE_FOX_TEXTURE := "res://Features/ArtistFlow/Art/Pets/Sprites/Sprite_WhiteFox.png"
const ACTIVE_GAME_SESSION_META := &"active_game_session"
const PARTY := &"party"
const BRONZE := &"bronze"
const SILVER := &"silver"
const GOLD := &"gold"


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	if has_meta(ACTIVE_GAME_SESSION_META):
		remove_meta(ACTIVE_GAME_SESSION_META)

	var error := change_scene_to_file(FLOATING_UI_SCENE)
	if error != OK:
		_fail("The test could not load the floating UI prefab.")
		return
	await process_frame
	await process_frame
	if current_scene == null or current_scene.scene_file_path != FLOATING_UI_SCENE:
		_fail("The test could not enter the floating UI scene.")
		return

	var middle := current_scene.get_node("MainBG/Containers/Middle")
	# This test validates storage state only. The dedicated merge animation smoke
	# test covers the asynchronous 0.8-second presentation.
	middle.set("_merge_animations_enabled", false)
	var fox := load(WHITE_FOX_TEXTURE) as Texture2D
	if fox == null:
		_fail("White fox test texture could not be loaded.")
		return

	# Reproduce the reported state: one existing silver plus a bronze card. A
	# shop bronze dropped directly onto it first makes another silver, which must
	# immediately merge again into gold.
	middle.call("_set_storage_item", PARTY, 0, fox, SILVER)
	middle.call("_set_storage_item", PARTY, 1, fox, BRONZE)
	if not middle.call("_receive_shop_item_in_storage", PARTY, 1, fox, BRONZE):
		_fail("The incoming bronze fox was not accepted.")
		return

	var party_items: Array = middle.get("_party_items")
	var party_qualities: Array = middle.get("_party_item_qualities")
	var occupied_count := 0
	var gold_count := 0
	for index in party_items.size():
		if party_items[index] == null:
			continue
		occupied_count += 1
		if party_qualities[index] == GOLD:
			gold_count += 1

	if occupied_count != 1 or gold_count != 1:
		_fail("Cascading merge did not reduce the three-card setup to one gold fox.")
		return

	print("Storage auto-merge smoke test passed.")
	var scene_to_free := current_scene
	current_scene = null
	scene_to_free.queue_free()
	await process_frame
	quit()


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
