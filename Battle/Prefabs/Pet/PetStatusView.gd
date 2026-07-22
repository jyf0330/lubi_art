@tool
extends Node

@export var hp_label_path: NodePath
@export var attack_label_path: NodePath
@export var damage_preview_label_path: NodePath

@onready var hp_label: Label = get_node(hp_label_path) as Label
@onready var attack_label: Label = get_node(attack_label_path) as Label
@onready var damage_preview_label: Label = get_node(damage_preview_label_path) as Label

var _data: Dictionary = {}


func _ready() -> void:
	_apply_readability_style()
	reset()


func reset() -> void:
	_data = {}
	if hp_label == null or attack_label == null or damage_preview_label == null:
		return
	hp_label.text = ""
	attack_label.text = ""
	damage_preview_label.text = ""
	damage_preview_label.visible = false


func bind_battle_data(data: Dictionary) -> void:
	_data = data.duplicate(true)
	update_hp(int(_data.get("hp", 0)))
	update_attack(int(_data.get("attack_damage", _data.get("attack", 0))))


func update_hp(value: int) -> void:
	_data["hp"] = value
	_set_stat_value(hp_label, max(0, value))


func update_attack(value: int) -> void:
	_data["attack_damage"] = value
	_set_stat_value(attack_label, max(0, value))


func show_damage_preview(value: int, visible: bool) -> void:
	damage_preview_label.text = "-%d" % max(0, value)
	damage_preview_label.visible = visible


func snapshot() -> Dictionary:
	return _data.duplicate(true)


func _set_stat_value(label: Label, value: int) -> void:
	if label == null:
		return
	label.text = str(value)
	var digit_count := label.text.length()
	var font_size := 30
	if digit_count == 3:
		font_size = 27
	elif digit_count >= 4:
		font_size = 23
	label.add_theme_font_size_override("font_size", font_size)


func _apply_readability_style() -> void:
	if hp_label == null or attack_label == null or damage_preview_label == null:
		return
	for label in [hp_label, attack_label]:
		label.add_theme_color_override("font_color", Color.WHITE)
		label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.95))
		label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.95))
		label.add_theme_constant_override("outline_size", 2)
		label.add_theme_constant_override("shadow_offset_x", 2)
		label.add_theme_constant_override("shadow_offset_y", 2)
		label.add_theme_constant_override("shadow_outline_size", 2)
	damage_preview_label.add_theme_color_override("font_color", Color(1.0, 0.22, 0.14))
	damage_preview_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.9))
	damage_preview_label.add_theme_constant_override("shadow_offset_x", 2)
	damage_preview_label.add_theme_constant_override("shadow_offset_y", 2)
	damage_preview_label.add_theme_font_size_override("font_size", 26)
