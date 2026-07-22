extends Control

signal screen_requested(screen_id: StringName, view_model: Dictionary)

const SAVE_GAME_SCENE := "res://Features/MainMenu/Views/SaveGameView.tscn"
const LOAD_GAME_SCENE := "res://Features/MainMenu/Views/LoadGameView.tscn"
const SCREEN_IDS := preload("res://Shared/Navigation/ScreenIds.gd")
const ABANDON_GAME_DIALOG := preload("res://Features/MainMenu/Views/AbandonGameDialog.tscn")
const MENU_SCENES := {
	SAVE_GAME_SCENE: preload("res://Features/MainMenu/Views/SaveGameView.tscn"),
	LOAD_GAME_SCENE: preload("res://Features/MainMenu/Views/LoadGameView.tscn"),
}
const ACTIVE_GAME_SESSION_META := &"active_game_session"

@onready var first_button: Button = $Menu/VBoxContainer/Settings
@onready var continue_button: Button = $Menu/VBoxContainer/Continue
@onready var save_game_button: Button = get_node("Menu/VBoxContainer/Save Game")
@onready var load_game_button: Button = get_node("Menu/VBoxContainer/Load Game")
@onready var main_menu_button: Button = get_node("Menu/VBoxContainer/Main Menu")
@onready var resign_button: Button = $Menu/VBoxContainer/Resign

var _abandon_game_dialog: Control
var _subscreen: Control


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	continue_button.pressed.connect(_continue_game)
	save_game_button.pressed.connect(_open_scene.bind(SAVE_GAME_SCENE))
	load_game_button.pressed.connect(_open_scene.bind(LOAD_GAME_SCENE))
	main_menu_button.pressed.connect(_return_to_main_menu)
	resign_button.pressed.connect(_open_abandon_game_dialog)
	first_button.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if is_instance_valid(_abandon_game_dialog):
		return

	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_continue_game()


func _open_scene(scene_path: String) -> void:
	if is_instance_valid(_subscreen):
		return
	var packed_scene := MENU_SCENES.get(scene_path) as PackedScene
	if packed_scene == null:
		push_error("Unknown settings subscreen: %s" % scene_path)
		return
	_subscreen = packed_scene.instantiate() as Control
	_subscreen.tree_exited.connect(_on_subscreen_closed)
	if _subscreen.has_signal("back_requested"):
		_subscreen.back_requested.connect(_close_subscreen)
	$Menu.hide()
	add_child(_subscreen)


func _continue_game() -> void:
	get_tree().paused = false
	queue_free()


func _open_abandon_game_dialog() -> void:
	if is_instance_valid(_abandon_game_dialog):
		return

	_abandon_game_dialog = ABANDON_GAME_DIALOG.instantiate() as Control
	_abandon_game_dialog.tree_exited.connect(_on_abandon_game_dialog_closed)
	_abandon_game_dialog.abandon_confirmed.connect(_on_abandon_confirmed)
	add_child(_abandon_game_dialog)


func _on_abandon_game_dialog_closed() -> void:
	_abandon_game_dialog = null
	if is_instance_valid(resign_button) and resign_button.is_inside_tree():
		resign_button.grab_focus()


func _on_abandon_confirmed() -> void:
	get_tree().paused = false
	screen_requested.emit(SCREEN_IDS.MAIN_MENU, {})
	queue_free()


func _return_to_main_menu() -> void:
	var game_scene := get_tree().current_scene
	if game_scene != null and game_scene.has_method("save_session_state"):
		game_scene.call("save_session_state")

	get_tree().set_meta(ACTIVE_GAME_SESSION_META, true)
	get_tree().paused = false
	screen_requested.emit(SCREEN_IDS.MAIN_MENU, {})
	queue_free()


func _close_subscreen() -> void:
	if is_instance_valid(_subscreen):
		_subscreen.queue_free()


func _on_subscreen_closed() -> void:
	_subscreen = null
	if is_instance_valid(self) and is_inside_tree():
		$Menu.show()
		first_button.grab_focus()
