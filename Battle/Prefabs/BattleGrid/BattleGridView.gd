@tool
extends Control

@export_category("Grid Colors")
@export var outer_area_color := Color("18222d"):
	set(value):
		outer_area_color = value
		queue_redraw()
@export var battle_board_color := Color("26394a"):
	set(value):
		battle_board_color = value
		queue_redraw()
@export var outer_grid_color := Color(0.55, 0.68, 0.76, 0.32):
	set(value):
		outer_grid_color = value
		queue_redraw()
@export var board_grid_color := Color(0.78, 0.9, 0.96, 0.58):
	set(value):
		board_grid_color = value
		queue_redraw()
@export var board_border_color := Color(0.95, 0.78, 0.34, 0.95):
	set(value):
		board_border_color = value
		queue_redraw()

@export_category("Grid Lines")
@export_range(1.0, 4.0, 0.5) var outer_grid_width := 1.0:
	set(value):
		outer_grid_width = value
		queue_redraw()
@export_range(1.0, 6.0, 0.5) var board_grid_width := 1.5:
	set(value):
		board_grid_width = value
		queue_redraw()
@export_range(1.0, 10.0, 0.5) var board_border_width := 4.0:
	set(value):
		board_border_width = value
		queue_redraw()

var _canvas_size := Vector2.ZERO
var _cell_size := 0.0
var _total_cells := Vector2i.ZERO
var _board_size_in_cells := Vector2i.ZERO
var _board_origin_in_cells := Vector2i.ZERO
var _board_rect := Rect2()


func setup(view_model: Dictionary) -> void:
	_canvas_size = Vector2(view_model.get("canvas_size", Vector2i.ZERO))
	_cell_size = float(view_model.get("cell_size", 0))
	_total_cells = Vector2i(view_model.get("total_cells", Vector2i.ZERO))
	_board_size_in_cells = Vector2i(view_model.get("board_size_in_cells", Vector2i.ZERO))
	_board_origin_in_cells = Vector2i(view_model.get("board_origin_in_cells", Vector2i.ZERO))
	_board_rect = Rect2(view_model.get("board_rect", Rect2()))
	custom_minimum_size = _canvas_size
	queue_redraw()


func get_layout_snapshot() -> Dictionary:
	return {
		"canvas_size": Vector2i(_canvas_size),
		"cell_size": int(_cell_size),
		"total_cells": _total_cells,
		"board_size_in_cells": _board_size_in_cells,
		"board_origin_in_cells": _board_origin_in_cells,
		"board_rect": _board_rect,
	}


func _draw() -> void:
	if _cell_size <= 0.0 or _canvas_size == Vector2.ZERO:
		return

	var canvas_rect := Rect2(Vector2.ZERO, _canvas_size)
	draw_rect(canvas_rect, outer_area_color)
	draw_rect(_board_rect, battle_board_color)

	_draw_grid(
		Vector2.ZERO,
		_total_cells,
		outer_grid_color,
		outer_grid_width
	)
	_draw_grid(
		_board_rect.position,
		_board_size_in_cells,
		board_grid_color,
		board_grid_width
	)
	draw_rect(_board_rect, board_border_color, false, board_border_width)


func _draw_grid(origin: Vector2, cell_count: Vector2i, color: Color, width: float) -> void:
	var grid_size := Vector2(cell_count) * _cell_size
	for column in range(cell_count.x + 1):
		var x := origin.x + float(column) * _cell_size
		draw_line(
			Vector2(x, origin.y),
			Vector2(x, origin.y + grid_size.y),
			color,
			width,
			true
		)
	for row in range(cell_count.y + 1):
		var y := origin.y + float(row) * _cell_size
		draw_line(
			Vector2(origin.x, y),
			Vector2(origin.x + grid_size.x, y),
			color,
			width,
			true
		)
