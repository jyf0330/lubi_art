extends Control

signal screen_requested(screen_id: StringName, view_model: Dictionary)

const DEBUG_BUTTON_PATH = "MainBG/DebugButton"
const SETTINGS_MENU_SCENE = preload("res://Features/MainMenu/Views/SettingsMenuView.tscn")
const MIDDLE_CONTROLLER_PATH = "MainBG/Containers/Middle"

var _settings_menu: Control = null

const REPLACEMENT_GROUPS = [
	{
		"container_path": "MainBG/Containers/Middle/Middle_Three_Option",
		"texture": preload("res://Features/ArtistFlow/Art/Debug/Images/Three_Qi.png"),
	},
	{
		"container_path": "MainBG/Containers/Middle/Middle_Shop",
		"texture": preload("res://Features/ArtistFlow/Art/Debug/Images/Shop_Xue.png"),
	},
	{
		"container_path": "MainBG/Containers/Middle/Middle_Bag",
		"texture": preload("res://Features/ArtistFlow/Art/Debug/Images/Bag_Ping.png"),
	},
	{
		"container_path": "MainBG/Containers/Party/Party_Container",
		"texture": preload("res://Features/ArtistFlow/Art/Debug/Images/Party_Tang.png"),
	},
]


func _ready() -> void:
	var middle_controller := get_node_or_null(MIDDLE_CONTROLLER_PATH)
	if middle_controller != null and middle_controller.has_signal("screen_requested"):
		middle_controller.screen_requested.connect(_on_screen_requested)
	var debug_button := get_node_or_null(DEBUG_BUTTON_PATH) as BaseButton
	if debug_button == null:
		push_warning("DebugButton not found at %s" % DEBUG_BUTTON_PATH)
		return

	debug_button.pressed.connect(_on_debug_button_pressed)


func _on_debug_button_pressed() -> void:
	for group in REPLACEMENT_GROUPS:
		var container_path := group["container_path"] as String
		var texture := group["texture"] as Texture2D
		var container := get_node_or_null(container_path)
		if container == null:
			push_warning("Replacement container not found: %s" % container_path)
			continue

		var replaced_count := _replace_texture_buttons(container, texture)
		if replaced_count == 0:
			push_warning("No TextureButton found under: %s" % container_path)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
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


func save_session_state() -> void:
	var middle_controller := get_node_or_null(MIDDLE_CONTROLLER_PATH)
	if middle_controller != null and middle_controller.has_method("save_session_state"):
		middle_controller.call("save_session_state")


func setup(view_model: Dictionary) -> void:
	var middle_controller := get_node_or_null(MIDDLE_CONTROLLER_PATH)
	if middle_controller != null and middle_controller.has_method("setup"):
		middle_controller.call("setup", view_model)


func refresh(view_model: Dictionary) -> void:
	var middle_controller := get_node_or_null(MIDDLE_CONTROLLER_PATH)
	if middle_controller != null and middle_controller.has_method("refresh"):
		middle_controller.call("refresh", view_model)


func _on_screen_requested(screen_id: StringName, view_model: Dictionary = {}) -> void:
	screen_requested.emit(screen_id, view_model)


func _replace_texture_buttons(node: Node, texture: Texture2D) -> int:
	var replaced_count := 0

	if node is TextureButton:
		node.texture_normal = texture
		replaced_count += 1

	for child in node.get_children():
		replaced_count += _replace_texture_buttons(child, texture)

	return replaced_count
