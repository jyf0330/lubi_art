extends RefCounted

# Mock layout data for the rebuilt battle screen. Replace this provider when
# the real battle-map configuration is available; the controller/view contract
# can stay unchanged.
const MOCK_GRID_LAYOUT := {
	"canvas_size": Vector2i(1920, 1080),
	"cell_size": 60,
	"board_size_in_cells": Vector2i(16, 16),
}


static func get_mock_grid_layout() -> Dictionary:
	return MOCK_GRID_LAYOUT.duplicate(true)
