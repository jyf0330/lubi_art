extends SceneTree

const FLOATING_UI_SCENE := "res://Features/ArtistFlow/Views/ArtistFlowView.tscn"
const WHITE_FOX_TEXTURE := "res://Shared/Art/Pets/Sprites/Sprite_WhiteFox.png"
const ACTIVE_GAME_SESSION_META := &"active_game_session"
const PARTY := &"party"
const BRONZE := &"bronze"
const EXPECTED_DURATION := 0.8


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
	if not is_equal_approx(float(middle.get("merge_animation_duration")), EXPECTED_DURATION):
		_fail("The merge animation duration is not 0.8 seconds.")
		return

	var fox := load(WHITE_FOX_TEXTURE) as Texture2D
	middle.call("_set_storage_item", PARTY, 0, fox, BRONZE)
	middle.call("_set_storage_item", PARTY, 1, fox, BRONZE)
	if not middle.call("_auto_merge_storage_item", PARTY, 1):
		_fail("The two setup cards did not merge.")
		return

	await process_frame
	var overlay := current_scene.get_node_or_null("MergeAnimationOverlay") as Control
	if overlay == null:
		_fail("The merge animation overlay was not created.")
		return
	if overlay.get_node_or_null("MergeSourceCard") == null \
		or overlay.get_node_or_null("MergeTargetCard") == null \
		or overlay.get_node_or_null("MergeBurst") == null:
		_fail("The merge animation is missing a card or local burst layer.")
		return
	for child in overlay.get_children():
		if child is ColorRect:
			_fail("The merge animation unexpectedly added a full-screen color overlay.")
			return

	var party_buttons: Array = middle.get("_party_buttons")
	var target_button := party_buttons[1] as TextureButton
	if target_button == null or target_button.modulate.a > 0.01:
		_fail("The real destination card was not hidden behind its animation clone.")
		return

	await create_timer(EXPECTED_DURATION + 0.08).timeout
	await process_frame
	if current_scene.get_node_or_null("MergeAnimationOverlay") != null:
		_fail("The merge animation did not finish within the configured duration.")
		return
	if not is_equal_approx(target_button.modulate.a, 1.0):
		_fail("The destination card stayed hidden after the animation completed.")
		return

	print("Merge animation smoke test passed.")
	var scene_to_free := current_scene
	current_scene = null
	scene_to_free.queue_free()
	await process_frame
	quit()


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
