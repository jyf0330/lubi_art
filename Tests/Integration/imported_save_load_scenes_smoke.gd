extends SceneTree

const SETTINGS_MENU_SCENE := "res://Features/MainMenu/Views/SettingsMenuView.tscn"
const SAVE_SCENE := "res://Features/MainMenu/Views/SaveGameView.tscn"
const LOAD_SCENE := "res://Features/MainMenu/Views/LoadGameView.tscn"


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var error := change_scene_to_file(SETTINGS_MENU_SCENE)
	if error != OK:
		push_error("Unable to load imported settings menu")
		quit(1)
		return
	await process_frame
	await process_frame

	current_scene.get_node("Menu/VBoxContainer/Save Game").pressed.emit()
	if not await _check_menu(SAVE_SCENE, "保存存档"):
		quit(1)
		return
	current_scene.get_node("Menu/VBoxContainer/Load Game").pressed.emit()
	if not await _check_menu(LOAD_SCENE, "载入存档"):
		quit(1)
		return

	print("Imported save/load scenes smoke test passed.")
	quit()


func _check_menu(scene_path: String, expected_title: String) -> bool:
	await process_frame
	await process_frame
	var subscreen := current_scene.get("_subscreen") as Control
	if subscreen == null or subscreen.scene_file_path != scene_path:
		push_error("Menu button did not open imported scene: %s" % scene_path)
		return false
	if subscreen.get_node("Menu/Title").text != expected_title:
		push_error("Imported scene title does not match: %s" % scene_path)
		return false

	subscreen.get_node("Menu/Back").pressed.emit()
	await process_frame
	await process_frame
	if current_scene.get("_subscreen") != null or not current_scene.get_node("Menu").visible:
		push_error("Back did not return to the settings menu from: %s" % scene_path)
		return false
	return true
