extends Control

const SAVE_GAME_SCENE := "res://Scenes/ui_save_game.tscn"
const LOAD_GAME_SCENE := "res://Scenes/ui_load_game.tscn"
const MAIN_MENU_SCENE := "res://Scenes/start_scene.tscn"
const ABANDON_GAME_DIALOG := preload("res://Scenes/ui_abandon_game.tscn")
const ACTIVE_GAME_SESSION_META := &"active_game_session"

@onready var first_button: Button = $Menu/VBoxContainer/Settings
@onready var continue_button: Button = $Menu/VBoxContainer/Continue
@onready var save_game_button: Button = get_node("Menu/VBoxContainer/Save Game")
@onready var load_game_button: Button = get_node("Menu/VBoxContainer/Load Game")
@onready var main_menu_button: Button = get_node("Menu/VBoxContainer/Main Menu")
@onready var resign_button: Button = $Menu/VBoxContainer/Resign

var _abandon_game_dialog: Control


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
	get_tree().paused = false
	var error := get_tree().change_scene_to_file(scene_path)
	if error != OK:
		push_error("Unable to open menu scene: %s" % scene_path)


func _continue_game() -> void:
	get_tree().paused = false
	queue_free()


func _open_abandon_game_dialog() -> void:
	if is_instance_valid(_abandon_game_dialog):
		return

	_abandon_game_dialog = ABANDON_GAME_DIALOG.instantiate() as Control
	_abandon_game_dialog.tree_exited.connect(_on_abandon_game_dialog_closed)
	add_child(_abandon_game_dialog)


func _on_abandon_game_dialog_closed() -> void:
	_abandon_game_dialog = null
	if is_instance_valid(resign_button) and resign_button.is_inside_tree():
		resign_button.grab_focus()


func _return_to_main_menu() -> void:
	var game_scene := get_tree().current_scene
	if game_scene != null and game_scene.has_method("save_session_state"):
		game_scene.call("save_session_state")

	get_tree().set_meta(ACTIVE_GAME_SESSION_META, true)
	get_tree().paused = false
	var error := get_tree().change_scene_to_file(MAIN_MENU_SCENE)
	if error != OK:
		push_error("Unable to return to main menu: %s" % MAIN_MENU_SCENE)
