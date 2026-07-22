extends Control

signal abandon_confirmed
signal cancel_requested

const MAIN_MENU_SCENE := "res://Scenes/start_scene.tscn"
const SETTINGS_MENU_SCENE := "res://Scenes/u_isettings_button.tscn"
const ACTIVE_GAME_SESSION_META := &"active_game_session"

@onready var confirm_button: Button = $Dialog/Buttons/Confirm
@onready var cancel_button: Button = $Dialog/Buttons/Cancel


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	confirm_button.pressed.connect(_confirm_abandon)
	cancel_button.pressed.connect(_cancel)
	cancel_button.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_cancel()


func _confirm_abandon() -> void:
	abandon_confirmed.emit()
	get_tree().remove_meta(ACTIVE_GAME_SESSION_META)
	get_tree().paused = false
	var error := get_tree().change_scene_to_file(MAIN_MENU_SCENE)
	if error != OK:
		push_error("Unable to abandon the game: %s" % MAIN_MENU_SCENE)


func _cancel() -> void:
	cancel_requested.emit()

	if get_tree().current_scene != self:
		queue_free()
		return

	get_tree().paused = false
	var error := get_tree().change_scene_to_file(SETTINGS_MENU_SCENE)
	if error != OK:
		push_error("Unable to return to the settings menu: %s" % SETTINGS_MENU_SCENE)
