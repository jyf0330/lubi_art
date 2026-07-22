extends Button

@export var hover_inner_border: StyleBox
@export_category("Save Slot")
@export var format_as_save_slot: bool = false
@export var save_slot_number: int = 0
@export var save_day: int = -1
@export var save_hour: int = -1

@onready var inner_border: Panel = $InnerBorder

var normal_inner_border: StyleBox


func _ready() -> void:
	if format_as_save_slot:
		_refresh_save_slot_text()

	normal_inner_border = inner_border.get_theme_stylebox("panel")
	mouse_entered.connect(_set_inner_border_hovered.bind(true))
	mouse_exited.connect(_set_inner_border_hovered.bind(false))


func _set_inner_border_hovered(is_hovered: bool) -> void:
	inner_border.add_theme_stylebox_override(
		"panel", hover_inner_border if is_hovered else normal_inner_border
	)


func set_save_time(day: int, hour: int) -> void:
	save_day = day
	save_hour = hour
	_refresh_save_slot_text()


func clear_save_time() -> void:
	save_day = -1
	save_hour = -1
	_refresh_save_slot_text()


func _refresh_save_slot_text() -> void:
	text = "存档 %02d · 第%s天 · 第%s小时" % [
		save_slot_number,
		_format_fixed_width_value(save_day, 3),
		_format_fixed_width_value(save_hour, 4),
	]


func _format_fixed_width_value(value: int, width: int) -> String:
	if value < 0:
		return " ".repeat(width)

	var digits := str(value)
	if digits.length() > width:
		return "-".repeat(width)

	return digits.lpad(width, " ")
