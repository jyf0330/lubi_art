extends Control

@onready var first_option: Button = $LeftButtonArea/Buttons/Option01
@onready var quit_button: Button = $LeftButtonArea/Buttons/Option07
@onready var close_button: ActionButton = $CloseButton


func _ready() -> void:
	quit_button.pressed.connect(_on_quit_pressed)
	close_button.button_pressed.connect(_on_close_button_pressed)


func open() -> void:
	show()
	first_option.grab_focus()


func close() -> void:
	hide()


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_close_button_pressed(action: ActionButton.ActionType) -> void:
	if action == ActionButton.ActionType.CLOSE:
		close()
