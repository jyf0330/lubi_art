extends Control

## Project-level art assembly entry point.
## Real game code can replace this controller while continuing to instantiate
## the same presentation prefabs through their public methods and signals.

signal screen_changed(screen_id: StringName, screen: Node)

const SCREEN_IDS := preload("res://Shared/Navigation/ScreenIds.gd")
const SCREEN_MAIN_MENU := SCREEN_IDS.MAIN_MENU
const SCREEN_ARTIST_FLOW := SCREEN_IDS.ARTIST_FLOW
const SCREEN_BATTLE := SCREEN_IDS.BATTLE
const SCREEN_SCENES: Dictionary = {
	SCREEN_MAIN_MENU: preload("res://Features/MainMenu/Views/MainMenuView.tscn"),
	SCREEN_ARTIST_FLOW: preload("res://Features/ArtistFlow/Views/ArtistFlowView.tscn"),
	SCREEN_BATTLE: preload("res://Features/Battle/Views/BattleMainView.tscn"),
}

@export var initial_screen: StringName = SCREEN_BATTLE

@onready var screen_host: Control = %ScreenHost

var _current_screen_id: StringName = &""
var _current_screen: Node


func _ready() -> void:
	show_screen(initial_screen)


func show_battle(view_model: Dictionary = {}) -> Node:
	return show_screen(SCREEN_BATTLE, view_model)


func show_main_menu(view_model: Dictionary = {}) -> Node:
	return show_screen(SCREEN_MAIN_MENU, view_model)


func show_artist_flow(view_model: Dictionary = {}) -> Node:
	return show_screen(SCREEN_ARTIST_FLOW, view_model)


func show_screen(screen_id: StringName, view_model: Dictionary = {}) -> Node:
	var packed_scene := SCREEN_SCENES.get(screen_id) as PackedScene
	if packed_scene == null:
		push_error("game has no registered art screen: %s" % screen_id)
		return null

	_clear_current_screen()
	_current_screen = packed_scene.instantiate()
	_current_screen.name = String(screen_id)
	screen_host.add_child(_current_screen)
	_current_screen_id = screen_id
	_bind_screen_requests(_current_screen)

	if _current_screen.has_method("setup"):
		_current_screen.call("setup", view_model)

	screen_changed.emit(_current_screen_id, _current_screen)
	return _current_screen


func get_current_screen() -> Node:
	return _current_screen


func get_current_screen_id() -> StringName:
	return _current_screen_id


func _bind_screen_requests(screen: Node) -> void:
	if not screen.has_signal("screen_requested"):
		return
	var request_callable := Callable(self, "_on_screen_requested")
	if not screen.is_connected("screen_requested", request_callable):
		screen.connect("screen_requested", request_callable)


func _on_screen_requested(screen_id: StringName, view_model: Dictionary = {}) -> void:
	show_screen(screen_id, view_model)


func _clear_current_screen() -> void:
	if not is_instance_valid(_current_screen):
		return
	if _current_screen.get_parent() == screen_host:
		screen_host.remove_child(_current_screen)
	_current_screen.queue_free()
	_current_screen = null
	_current_screen_id = &""
