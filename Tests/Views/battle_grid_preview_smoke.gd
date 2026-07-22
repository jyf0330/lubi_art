extends SceneTree

const BATTLE_GRID_PREVIEW := "res://Features/Battle/Preview/BattleGridPreview.tscn"


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var packed_scene := load(BATTLE_GRID_PREVIEW) as PackedScene
	if packed_scene == null:
		_fail("Unable to load BattleGridPreview")
		return

	var scene := packed_scene.instantiate()
	root.add_child(scene)
	await process_frame
	await process_frame

	var grid_view := scene.get_node_or_null("BattleGridView")
	if grid_view == null:
		_fail("BattleGridPreview has no BattleGridView prefab")
		return

	var layout: Dictionary = grid_view.call("get_layout_snapshot")
	if layout.get("canvas_size") != Vector2i(1920, 1080):
		_fail("Grid canvas is not 1920x1080")
		return
	if layout.get("cell_size") != 60:
		_fail("Grid cells are not 60x60")
		return
	if layout.get("total_cells") != Vector2i(32, 18):
		_fail("Full grid is not 32x18")
		return
	if layout.get("board_size_in_cells") != Vector2i(16, 16):
		_fail("Battle board is not 16x16")
		return
	if layout.get("board_origin_in_cells") != Vector2i(8, 1):
		_fail("Battle board does not have 8 side cells and 1 top/bottom cell")
		return
	if layout.get("board_rect") != Rect2(480.0, 60.0, 960.0, 960.0):
		_fail("Battle board is not centered at (480, 60)")
		return

	print("Battle grid preview smoke test passed.")
	scene.queue_free()
	await process_frame
	quit()


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
