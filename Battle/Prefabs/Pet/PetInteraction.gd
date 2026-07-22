@tool
extends Node

var _view: Control = null
var _context := &"none"
var _side := ""
var _selected := false
var _dragging := false


func configure(view: Control) -> void:
	_view = view
	reset()


func reset() -> void:
	_context = &"none"
	_side = ""
	_selected = false
	_dragging = false
	if _view != null:
		_view.modulate = Color.WHITE
		_view.z_index = 0


func bind_context(context: StringName, side: String) -> void:
	_context = context
	_side = side


func set_selected(selected: bool) -> void:
	_selected = selected
	if _view != null and not _dragging:
		_view.modulate = Color(1.0, 0.96, 0.72, 1.0) if selected else Color.WHITE


func set_dragging(dragging: bool) -> void:
	_dragging = dragging
	if _view == null:
		return
	_view.z_index = 40 if dragging else 10
	_view.modulate = Color(1.0, 1.0, 1.0, 0.82) if dragging else (Color(1.0, 0.96, 0.72, 1.0) if _selected else Color.WHITE)


func snapshot() -> Dictionary:
	return {
		"context": String(_context),
		"side": _side,
		"selected": _selected,
		"dragging": _dragging,
	}
