extends Control
class_name GoldCounterView

signal value_changed(value: int)

@onready var value_label: Label = $GoldLabel

var _value := 0


func setup(view_model: Dictionary) -> void:
	set_value(int(view_model.get("value", view_model.get("coins", 0))))


func refresh(view_model: Dictionary) -> void:
	setup(view_model)


func set_value(value: int) -> void:
	_value = maxi(0, value)
	if is_instance_valid(value_label):
		value_label.text = str(_value)
	value_changed.emit(_value)


func get_value() -> int:
	return _value
