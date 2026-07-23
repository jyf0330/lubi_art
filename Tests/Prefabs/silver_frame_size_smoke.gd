extends SceneTree

const FLOATING_UI_SCENE := "res://Features/ArtistFlow/Views/ArtistFlowView.tscn"
const CREATURE_TEXTURE_PATH := "res://Shared/Art/Pets/Sprites/Sprite_WhiteFox.png"
const SILVER_QUALITY := &"silver"
const EXPECTED_FRAME_SIZE := Vector2(238.0, 238.0)
const EXPECTED_FRAME_POSITION := Vector2(-9.0, -9.0)


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	change_scene_to_packed(load(FLOATING_UI_SCENE) as PackedScene)
	await scene_changed
	var scene := current_scene
	await process_frame

	var middle := scene.get_node("MainBG/Containers/Middle")
	var button := scene.get_node(
		"MainBG/Containers/Middle/Middle_Shop/Shop_Slot/Shop_Button"
	) as TextureButton
	var creature_texture := load(CREATURE_TEXTURE_PATH) as Texture2D
	middle.call("_set_creature_item_texture", button, creature_texture, SILVER_QUALITY)

	var slot := button.get_parent() as CreatureSlotView
	var presentation := slot.get_collection_presentation_snapshot()
	var frame_size := Vector2(presentation.get("frame_size", Vector2.ZERO))
	if not frame_size.is_equal_approx(EXPECTED_FRAME_SIZE):
		push_error("Silver card frame render size is incorrect: %s" % frame_size)
		quit(1)
		return
	var frame_position := Vector2(presentation.get("frame_position", Vector2.ZERO))
	if not frame_position.is_equal_approx(EXPECTED_FRAME_POSITION):
		push_error("Silver card frame position is incorrect: %s" % frame_position)
		quit(1)
		return

	var expected_scale := EXPECTED_FRAME_SIZE.x / 220.0
	var topper_scale := Vector2(presentation.get("topper_scale", Vector2.ZERO))
	if not is_equal_approx(topper_scale.x, expected_scale):
		push_error("Silver card topper scale is incorrect: %s" % topper_scale)
		quit(1)
		return

	print("Silver frame size smoke test passed.")
	quit()
