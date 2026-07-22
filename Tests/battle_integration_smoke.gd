extends SceneTree

const FLOATING_UI_SCENE := "res://FloatingUI/Scenes/UI.tscn"
const BATTLE_SCENE := "res://Battle/Scenes/battle_main_scene.tscn"
const RETURN_FROM_BATTLE_META := &"returning_from_battle"


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var error := change_scene_to_file(FLOATING_UI_SCENE)
	if error != OK:
		push_error("无法加载三选界面")
		quit(1)
		return

	await process_frame
	await process_frame

	var middle := current_scene.get_node("MainBG/Containers/Middle")
	middle.call("_go_to_battle")
	await create_timer(0.75).timeout
	if current_scene == null or current_scene.scene_file_path != BATTLE_SCENE:
		push_error("三选界面未进入项目内战斗场景")
		quit(1)
		return

	var board := current_scene.get_node("BoardGrid")
	board.call("_return_to_three_option_after_victory")
	await create_timer(0.9).timeout
	if current_scene == null or current_scene.scene_file_path != FLOATING_UI_SCENE:
		push_error("战斗场景未返回三选界面")
		quit(1)
		return

	if has_meta(RETURN_FROM_BATTLE_META):
		push_error("战斗返回标记未在三选界面消费")
		quit(1)
		return

	print("Battle integration smoke test passed.")
	quit()
