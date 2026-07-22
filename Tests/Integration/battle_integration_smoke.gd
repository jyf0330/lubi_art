extends SceneTree

const GAME_SCENE := "res://Game/Scenes/game.tscn"
const RETURN_FROM_BATTLE_META := &"returning_from_battle"


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var error := change_scene_to_file(GAME_SCENE)
	if error != OK:
		push_error("无法加载 game 主场景")
		quit(1)
		return

	await process_frame
	await process_frame

	var game := current_scene
	var artist_flow := game.call("show_artist_flow") as Control
	await process_frame
	var middle := artist_flow.get_node("MainBG/Containers/Middle")
	middle.call("_go_to_battle")
	await create_timer(0.75).timeout
	if game.call("get_current_screen_id") != &"battle":
		push_error("三选界面未进入项目内战斗场景")
		quit(1)
		return

	var battle := game.call("get_current_screen") as Control
	var board := battle.get_node("BoardGrid")
	board.call("_return_to_three_option_after_victory")
	await create_timer(0.9).timeout
	if game.call("get_current_screen_id") != &"artist_flow":
		push_error("战斗场景未返回三选界面")
		quit(1)
		return

	if has_meta(RETURN_FROM_BATTLE_META):
		push_error("战斗返回标记未在三选界面消费")
		quit(1)
		return

	print("Battle integration smoke test passed.")
	quit()
