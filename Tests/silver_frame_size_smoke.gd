extends SceneTree

const FLOATING_UI_SCENE := "res://FloatingUI/Scenes/UI.tscn"
const CREATURE_TEXTURE_PATH := "res://FloatingUI/SpriteImages/Sprite_WhiteFox.png"
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

	var frame := button.get_node("CreatureFrame") as TextureRect
	if not frame.size.is_equal_approx(EXPECTED_FRAME_SIZE):
		push_error("Silver card frame render size is incorrect: %s" % frame.size)
		quit(1)
		return
	if not frame.position.is_equal_approx(EXPECTED_FRAME_POSITION):
		push_error("Silver card frame position is incorrect: %s" % frame.position)
		quit(1)
		return

	var topper := button.get_node("CreatureTopper") as Sprite2D
	var expected_scale := EXPECTED_FRAME_SIZE.x / 220.0
	if not is_equal_approx(topper.scale.x, expected_scale):
		push_error("Silver card topper scale is incorrect: %s" % topper.scale)
		quit(1)
		return

	print("Silver frame size smoke test passed.")
	quit()
