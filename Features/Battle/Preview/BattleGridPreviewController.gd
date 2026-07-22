@tool
extends Control

const GRID_DATA := preload("res://Features/Battle/Preview/BattleGridPreviewData.gd")

@onready var battle_grid_view: Control = $BattleGridView


func _ready() -> void:
	refresh_grid()


func refresh_grid() -> void:
	var layout := GRID_DATA.get_mock_grid_layout()
	var view_model := _make_grid_view_model(layout)
	if view_model.is_empty():
		return
	battle_grid_view.call("setup", view_model)


func _make_grid_view_model(layout: Dictionary) -> Dictionary:
	var canvas_size := Vector2i(layout.get("canvas_size", Vector2i.ZERO))
	var cell_size := int(layout.get("cell_size", 0))
	var board_size := Vector2i(layout.get("board_size_in_cells", Vector2i.ZERO))
	if cell_size <= 0 or canvas_size.x <= 0 or canvas_size.y <= 0:
		push_error("BattleGridPreview layout has invalid dimensions.")
		return {}
	if canvas_size.x % cell_size != 0 or canvas_size.y % cell_size != 0:
		push_error("BattleGridPreview cell size must divide the canvas without gaps.")
		return {}

	var total_cells := Vector2i(canvas_size.x / cell_size, canvas_size.y / cell_size)
	if board_size.x <= 0 or board_size.y <= 0 or board_size.x > total_cells.x or board_size.y > total_cells.y:
		push_error("BattleGridPreview board size must fit inside the full grid.")
		return {}
	if (total_cells.x - board_size.x) % 2 != 0 or (total_cells.y - board_size.y) % 2 != 0:
		push_error("BattleGridPreview board cannot be centered on whole grid cells.")
		return {}

	var board_origin_in_cells := (total_cells - board_size) / 2
	var board_position := Vector2(board_origin_in_cells * cell_size)
	var board_pixel_size := Vector2(board_size * cell_size)
	return {
		"canvas_size": canvas_size,
		"cell_size": cell_size,
		"total_cells": total_cells,
		"board_size_in_cells": board_size,
		"board_origin_in_cells": board_origin_in_cells,
		"board_rect": Rect2(board_position, board_pixel_size),
	}
