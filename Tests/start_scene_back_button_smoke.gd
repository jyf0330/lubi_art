extends SceneTree

const START_SCENE := "res://Scenes/start_scene.tscn"
const ACTIVE_GAME_SESSION_META := &"active_game_session"


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	set_meta(ACTIVE_GAME_SESSION_META, true)
	var error := change_scene_to_file(START_SCENE)
	if error != OK:
		_fail("Unable to load the start scene")
		return
	await process_frame
	await process_frame

	var back_button: ActionButton = current_scene.get_node("BackButton")
	var settings_button: ActionButton = current_scene.get_node("SettingsButton")
	if not back_button.visible:
		_fail("Back button is hidden while a game can be continued")
		return
	if back_button.size != settings_button.size:
		_fail("Back button size does not match the settings button")
		return
	if not is_equal_approx(back_button.position.x, 1920.0 - settings_button.position.x - settings_button.size.x):
		_fail("Back button is not horizontally mirrored from the settings button")
		return
	if not is_equal_approx(back_button.position.y, settings_button.position.y):
		_fail("Back button vertical position does not match the settings button")
		return

	back_button.button_pressed.emit(ActionButton.ActionType.BACK)
	await process_frame
	var dialog := current_scene.get_node_or_null("ui_abandon_game")
	if dialog == null:
		_fail("Back button did not open the abandon-game dialog")
		return

	dialog.get_node("Dialog/Buttons/Cancel").pressed.emit()
	await process_frame
	if current_scene.get_node_or_null("ui_abandon_game") != null:
		_fail("Cancel did not close the abandon-game dialog")
		return

	back_button.button_pressed.emit(ActionButton.ActionType.BACK)
	await process_frame
	dialog = current_scene.get_node("ui_abandon_game")
	dialog.get_node("Dialog/Buttons/Confirm").pressed.emit()
	await process_frame
	await process_frame

	if current_scene == null or current_scene.scene_file_path != START_SCENE:
		_fail("Confirm did not return to the new-game screen")
		return
	if has_meta(ACTIVE_GAME_SESSION_META):
		_fail("Confirm did not clear the active game session")
		return
	if current_scene.get_node("BackButton").visible:
		_fail("Back button remains visible without an active game session")
		return

	print("Start scene back button smoke test passed.")
	quit()


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
