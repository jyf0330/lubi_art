extends SceneTree

const BATTLE_SCENE := "res://Battle/Scenes/battle_main_scene.tscn"
const SETTINGS_MENU_NODE := "UISettingsButton"


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var battle_scene := (load(BATTLE_SCENE) as PackedScene).instantiate()
	root.add_child(battle_scene)
	current_scene = battle_scene
	await process_frame

	var cancel_event := InputEventAction.new()
	cancel_event.action = "ui_cancel"
	cancel_event.pressed = true
	battle_scene._unhandled_input(cancel_event)
	await process_frame

	if not paused:
		_fail("Esc did not pause the battle")
		return

	var settings_menu := battle_scene.get_node_or_null(SETTINGS_MENU_NODE)
	if settings_menu == null:
		_fail("Esc did not open the in-game settings menu during battle")
		return

	settings_menu._unhandled_input(cancel_event)
	await process_frame
	if paused or battle_scene.get_node_or_null(SETTINGS_MENU_NODE) != null:
		_fail("A second Esc press did not close the battle settings menu")
		return

	print("Battle settings Esc smoke test passed.")
	quit()


func _fail(message: String) -> void:
	push_error(message)
	paused = false
	quit(1)
