@tool
extends PanelContainer
class_name SpriteInfoAttackPatternView

const GRID_COLUMNS := 7
const GRID_ROWS := 3
const CELL_COUNT := GRID_COLUMNS * GRID_ROWS
const CELL_SCENE := preload("res://Shared/Prefabs/Pet/SpriteInfo/SpriteInfoAttackCellView.tscn")

@onready var attack_cells: GridContainer = $AttackMargin/AttackLayout/AttackCells

var _cells: Array[SpriteInfoAttackCellView] = []


func _ready() -> void:
	_ensure_cells()


func refresh(info: SpriteInfoData, art_textures: Dictionary) -> void:
	_ensure_cells()

	var origin_index := clampi(info.origin_cell_index, 0, CELL_COUNT - 1)
	var hit_lookup := {}
	for hit_index in info.hit_cell_indices:
		if hit_index >= 0 and hit_index < CELL_COUNT:
			hit_lookup[hit_index] = true

	for index in CELL_COUNT:
		var cell := _cells[index]
		cell.clear()
		if index == origin_index:
			cell.setup(
				art_textures.get("精灵位置", null) as Texture2D,
				"●",
				Color(0.05, 0.42, 0.82, 1.0)
			)
		elif hit_lookup.has(index):
			cell.setup(
				art_textures.get("攻击落点", null) as Texture2D,
				"■",
				Color(0.86, 0.16, 0.12, 1.0)
			)


func clear() -> void:
	_ensure_cells()
	for cell in _cells:
		cell.clear()


func get_cell_count() -> int:
	_ensure_cells()
	return _cells.size()


func _ensure_cells() -> void:
	if attack_cells == null:
		return

	_cells.clear()
	for child in attack_cells.get_children():
		if child is SpriteInfoAttackCellView:
			_cells.append(child as SpriteInfoAttackCellView)

	while _cells.size() < CELL_COUNT:
		var cell := CELL_SCENE.instantiate() as SpriteInfoAttackCellView
		attack_cells.add_child(cell)
		_cells.append(cell)

	while _cells.size() > CELL_COUNT:
		var extra: SpriteInfoAttackCellView = _cells.pop_back() as SpriteInfoAttackCellView
		attack_cells.remove_child(extra)
		extra.queue_free()
