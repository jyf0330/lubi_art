@tool
extends Control

signal screen_requested(screen_id: StringName, view_model: Dictionary)

const GOLD_STATE_PATH := "user://three_option_shared_state.cfg"
const GOLD_STATE_SECTION := "player"
const GOLD_STATE_KEY := "gold"
const INITIAL_GOLD := 15
const SETTINGS_MENU_SCENE := preload("res://Features/MainMenu/Views/SettingsMenuView.tscn")
const BATTLE_BACKGROUND_TEXTURES: Array[Texture2D] = [
	preload("res://Features/Battle/Art/UI/battle_bg/bg1(1).png"),
	preload("res://Features/Battle/Art/UI/battle_bg/bg2.png"),
	preload("res://Features/Battle/Art/UI/battle_bg/bg3.png"),
]

@onready var gold_label: Label = $GoldCounter/GoldLabel
@onready var board_background: TextureRect = $BoardBG
@onready var board_controller: Control = $BoardGrid

var _gold := INITIAL_GOLD
var _random := RandomNumberGenerator.new()
var _settings_menu: Control


func _ready() -> void:
	_random.randomize()
	board_background.texture = BATTLE_BACKGROUND_TEXTURES[_random.randi_range(0, BATTLE_BACKGROUND_TEXTURES.size() - 1)]
	if Engine.is_editor_hint():
		return
	if board_controller.has_signal("screen_requested"):
		board_controller.screen_requested.connect(_on_screen_requested)

	_load_gold_state()
	_update_gold_display()


func setup(view_model: Dictionary) -> void:
	if board_controller.has_method("setup"):
		board_controller.call("setup", view_model)


func refresh(view_model: Dictionary) -> void:
	setup(view_model)


func _unhandled_input(event: InputEvent) -> void:
	if Engine.is_editor_hint() or not event.is_action_pressed("ui_cancel"):
		return

	get_viewport().set_input_as_handled()
	_open_settings_menu()


func _open_settings_menu() -> void:
	if is_instance_valid(_settings_menu):
		return

	_settings_menu = SETTINGS_MENU_SCENE.instantiate() as Control
	_settings_menu.tree_exited.connect(_on_settings_menu_closed)
	if _settings_menu.has_signal("screen_requested"):
		_settings_menu.screen_requested.connect(_on_screen_requested)
	add_child(_settings_menu)
	get_tree().paused = true


func _on_settings_menu_closed() -> void:
	_settings_menu = null


func _on_screen_requested(screen_id: StringName, view_model: Dictionary = {}) -> void:
	get_tree().paused = false
	screen_requested.emit(screen_id, view_model)


func _load_gold_state() -> void:
	var config := ConfigFile.new()
	var error := config.load(GOLD_STATE_PATH)
	if error == OK:
		_gold = max(0, int(config.get_value(GOLD_STATE_SECTION, GOLD_STATE_KEY, INITIAL_GOLD)))
	else:
		_gold = INITIAL_GOLD
		_save_gold_state()


func _save_gold_state() -> void:
	var config := ConfigFile.new()
	config.set_value(GOLD_STATE_SECTION, GOLD_STATE_KEY, _gold)
	var error := config.save(GOLD_STATE_PATH)
	if error != OK:
		push_warning("Failed to save gold state: %s" % GOLD_STATE_PATH)


func _update_gold_display() -> void:
	if gold_label != null:
		gold_label.text = str(_gold)
