extends Control

signal back_requested

const DEFAULT_RETURN_SCENE := "res://Scenes/u_isettings_button.tscn"

@export_file("*.tscn") var return_scene_path := DEFAULT_RETURN_SCENE

@onready var back_button: Button = $Menu/Back
@onready var first_save_slot: Button = $Menu/SaveSlots/SaveSlot1


func _ready() -> void:
	back_button.pressed.connect(_return_to_previous_screen)
	first_save_slot.grab_focus()


func open() -> void:
	show()
	first_save_slot.grab_focus()


func close() -> void:
	hide()


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		_return_to_previous_screen()
		get_viewport().set_input_as_handled()


func _return_to_previous_screen() -> void:
	back_requested.emit()

	# When embedded as an overlay, returning only closes this panel. When the
	# scene is run directly, return to the project's start scene instead.
	if get_tree().current_scene != self:
		close()
		return

	var error := get_tree().change_scene_to_file(return_scene_path)
	if error != OK:
		push_error("Unable to return to scene: %s" % return_scene_path)
