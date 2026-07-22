extends Control
class_name BattleActionPanelView

signal auto_arrange_requested
signal begin_turn_requested

@onready var auto_arrange_button: TextureButton = $AutoArrangeButton
@onready var begin_turn_button: TextureButton = $BeginTurnButton


func _ready() -> void:
	auto_arrange_button.pressed.connect(func() -> void: auto_arrange_requested.emit())
	begin_turn_button.pressed.connect(func() -> void: begin_turn_requested.emit())


func setup(view_model: Dictionary) -> void:
	auto_arrange_button.disabled = bool(view_model.get("auto_arrange_disabled", false))
	begin_turn_button.disabled = bool(view_model.get("begin_turn_disabled", false))


func refresh(view_model: Dictionary) -> void:
	setup(view_model)


func get_auto_arrange_button() -> TextureButton:
	return auto_arrange_button


func get_begin_turn_button() -> TextureButton:
	return begin_turn_button
