extends Control

signal screen_requested(screen_id: StringName, view_model: Dictionary)

const SCREEN_IDS := preload("res://Shared/Navigation/ScreenIds.gd")
const ABANDON_GAME_DIALOG := preload("res://Features/MainMenu/Views/AbandonGameDialog.tscn")
const ACTIVE_GAME_SESSION_META := &"active_game_session"
const RESTORE_GAME_SESSION_META := &"returning_from_battle"

@onready var start_game_button: FantasyGameButton = $StartGameButton
@onready var back_button: ActionButton = $BackButton
@onready var settings_button: ActionButton = $SettingsButton
@onready var settings_overlay = $SettingsOverlay

var _abandon_game_dialog: Control


func _ready() -> void:
	start_game_button.button_pressed.connect(_on_start_game_pressed)
	back_button.button_pressed.connect(_on_action_button_pressed)
	settings_button.button_pressed.connect(_on_action_button_pressed)
	var has_active_game := _has_active_game_session()
	back_button.visible = has_active_game
	if has_active_game:
		start_game_button.button_text = "继续游戏"


func setup(_view_model: Dictionary) -> void:
	refresh({})


func refresh(_view_model: Dictionary) -> void:
	var has_active_game := _has_active_game_session()
	back_button.visible = has_active_game
	start_game_button.button_text = "继续游戏" if has_active_game else "开始游戏"


func _on_start_game_pressed() -> void:
	if _has_active_game_session():
		get_tree().set_meta(RESTORE_GAME_SESSION_META, true)
	else:
		get_tree().set_meta(ACTIVE_GAME_SESSION_META, true)
	screen_requested.emit(SCREEN_IDS.ARTIST_FLOW, {})


func _has_active_game_session() -> bool:
	return get_tree().has_meta(ACTIVE_GAME_SESSION_META) \
		and bool(get_tree().get_meta(ACTIVE_GAME_SESSION_META))


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel"):
		return
	if is_instance_valid(_abandon_game_dialog):
		return

	if settings_overlay.visible:
		settings_overlay.close()
	else:
		settings_overlay.open()
	get_viewport().set_input_as_handled()


func _on_action_button_pressed(action: ActionButton.ActionType) -> void:
	match action:
		ActionButton.ActionType.BACK:
			_open_abandon_game_dialog()
		ActionButton.ActionType.SETTINGS:
			settings_overlay.open()


func _open_abandon_game_dialog() -> void:
	if not _has_active_game_session() or is_instance_valid(_abandon_game_dialog):
		return

	_abandon_game_dialog = ABANDON_GAME_DIALOG.instantiate() as Control
	_abandon_game_dialog.tree_exited.connect(_on_abandon_game_dialog_closed)
	_abandon_game_dialog.abandon_confirmed.connect(_on_abandon_confirmed)
	add_child(_abandon_game_dialog)


func _on_abandon_game_dialog_closed() -> void:
	_abandon_game_dialog = null


func _on_abandon_confirmed() -> void:
	refresh({})
	screen_requested.emit(SCREEN_IDS.MAIN_MENU, {})
