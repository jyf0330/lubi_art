extends SceneTree

const START_SCENE := "res://Scenes/start_scene.tscn"


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var error := change_scene_to_file(START_SCENE)
	if error != OK:
		_fail("Unable to load the start scene")
		return
	await process_frame
	await process_frame

	var settings_overlay: Control = current_scene.get_node("SettingsOverlay")
	if settings_overlay.visible:
		_fail("Start-scene settings are visible before Esc is pressed")
		return

	_press_escape()
	await process_frame
	if not settings_overlay.visible:
		_fail("Esc did not open the start-scene settings")
		return

	_press_escape()
	await process_frame
	if settings_overlay.visible:
		_fail("A second Esc press did not close the start-scene settings")
		return

	print("Start scene settings Esc smoke test passed.")
	quit()


func _press_escape() -> void:
	var cancel_event := InputEventAction.new()
	cancel_event.action = "ui_cancel"
	cancel_event.pressed = true
	Input.parse_input_event(cancel_event)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
