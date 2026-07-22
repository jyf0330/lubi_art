extends SceneTree

const GAME_SCENE := "res://Game/Scenes/game.tscn"
const SETTINGS_MENU_NODE := "UISettingsButton"
const ACTIVE_GAME_SESSION_META := &"active_game_session"
const TEST_TIME_NODE := 8


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	if has_meta(ACTIVE_GAME_SESSION_META):
		remove_meta(ACTIVE_GAME_SESSION_META)
	var error := change_scene_to_file(GAME_SCENE)
	if error != OK:
		push_error("无法加载 game 主场景")
		quit(1)
		return
	await process_frame
	await process_frame
	var game := current_scene
	var start_scene := game.call("show_main_menu") as Control
	await process_frame

	start_scene.get_node("StartGameButton").button_pressed.emit()
	await process_frame
	await process_frame
	if game.call("get_current_screen_id") != &"artist_flow":
		push_error("开始游戏未进入浮窗界面")
		quit(1)
		return

	var artist_flow := game.call("get_current_screen") as Control
	var main_bg := artist_flow.get_node("MainBG") as TextureRect
	if main_bg.texture == null or main_bg.texture.resource_path != "res://Features/Battle/Art/UI/battle_bg/bg3.png":
		push_error("Three-option screen is not using the shared clean background")
		quit(1)
		return
	var background_frame := main_bg.get_node_or_null("BackgroundFrame") as TextureRect
	if background_frame == null or background_frame.texture == null:
		push_error("Three-option screen is missing the shared decorative frame")
		quit(1)
		return
	if background_frame.texture.resource_path != "res://Features/Battle/Art/UI/battle_interface_frame_2.png":
		push_error("Three-option screen is not using the combined frame and clock base")
		quit(1)
		return
	var clock_indicator := main_bg.get_node_or_null("ClockIndicator") as Node2D
	if clock_indicator == null or not clock_indicator.position.is_equal_approx(Vector2(22.0, 519.0)):
		push_error("Three-option screen clock is not synchronized with battle")
		quit(1)
		return

	var middle_controller := artist_flow.get_node("MainBG/Containers/Middle")
	middle_controller.call("_set_clock_total_hours", TEST_TIME_NODE)
	middle_controller.call("save_session_state")

	var cancel_event := InputEventAction.new()
	cancel_event.action = "ui_cancel"
	cancel_event.pressed = true
	artist_flow._unhandled_input(cancel_event)
	await process_frame
	if not paused:
		push_error("Esc 未暂停游戏")
		quit(1)
		return

	var settings_menu := artist_flow.get_node_or_null(SETTINGS_MENU_NODE)
	if settings_menu == null:
		push_error("Esc 未打开游戏设置窗口")
		quit(1)
		return

	settings_menu.get_node("Menu/VBoxContainer/Main Menu").pressed.emit()
	await process_frame
	await process_frame
	if game.call("get_current_screen_id") != &"main_menu":
		push_error("退至主菜单未返回开始界面")
		quit(1)
		return

	start_scene = game.call("get_current_screen") as Control
	var start_button = start_scene.get_node("StartGameButton")
	if start_button.button_text != "继续游戏":
		push_error("返回主菜单后未显示继续游戏")
		quit(1)
		return

	start_button.button_pressed.emit()
	await process_frame
	await process_frame
	if game.call("get_current_screen_id") != &"artist_flow":
		push_error("继续游戏未返回浮窗界面")
		quit(1)
		return


	artist_flow = game.call("get_current_screen") as Control
	var restored_middle := artist_flow.get_node("MainBG/Containers/Middle")
	if int(restored_middle.get("_clock_total_hours")) != TEST_TIME_NODE:
		push_error("继续游戏未恢复到离开时的时间节点")
		quit(1)
		return

	print("Floating UI navigation smoke test passed.")
	quit()
