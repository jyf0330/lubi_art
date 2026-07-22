extends SceneTree

const SETTINGS_MENU_SCENE := "res://Scenes/u_isettings_button.tscn"
const START_SCENE := "res://Scenes/start_scene.tscn"
const ACTIVE_GAME_SESSION_META := &"active_game_session"


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	set_meta(ACTIVE_GAME_SESSION_META, true)
	var error := change_scene_to_file(SETTINGS_MENU_SCENE)
	if error != OK:
		_fail("无法加载游戏设置菜单")
		return
	await process_frame
	await process_frame

	var resign_button: Button = current_scene.get_node("Menu/VBoxContainer/Resign")
	resign_button.pressed.emit()
	await process_frame

	var dialog := current_scene.get_node_or_null("ui_abandon_game")
	if dialog == null:
		_fail("放弃按钮没有打开确认框")
		return
	if dialog.get_node("Dialog/Question").text != "确认要放弃游戏吗？":
		_fail("确认框提示文字不正确")
		return

	dialog.get_node("Dialog/Buttons/Cancel").pressed.emit()
	await process_frame
	if current_scene.get_node_or_null("ui_abandon_game") != null:
		_fail("取消按钮没有关闭确认框")
		return

	resign_button.pressed.emit()
	await process_frame
	dialog = current_scene.get_node("ui_abandon_game")
	dialog.get_node("Dialog/Buttons/Confirm").pressed.emit()
	await process_frame
	await process_frame

	if current_scene == null or current_scene.scene_file_path != START_SCENE:
		_fail("确认放弃后没有返回主菜单")
		return
	if has_meta(ACTIVE_GAME_SESSION_META):
		_fail("确认放弃后仍保留了游戏进度标记")
		return

	print("Abandon game dialog smoke test passed.")
	quit()


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
