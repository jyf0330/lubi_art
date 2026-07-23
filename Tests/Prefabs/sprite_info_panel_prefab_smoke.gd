extends SceneTree

const PANEL_SCENE_PATH := "res://Shared/Prefabs/Pet/SpriteInfoPanel.tscn"
const PANEL_SCRIPT_PATH := "res://Shared/Prefabs/Pet/SpriteInfoPanel.gd"
const BATTLE_UNIT_SCRIPT_PATH := "res://Features/Battle/Prefabs/Units/BattleUnit/BattleUnit.gd"

const COMPONENT_PATHS := {
	"PanelBackground/ContentMargin/Layout/SpriteInfoHeaderView": "res://Shared/Prefabs/Pet/SpriteInfo/SpriteInfoHeaderView.tscn",
	"PanelBackground/ContentMargin/Layout/SpriteInfoAttackPatternView": "res://Shared/Prefabs/Pet/SpriteInfo/SpriteInfoAttackPatternView.tscn",
	"PanelBackground/ContentMargin/Layout/SpriteInfoStatTableView": "res://Shared/Prefabs/Pet/SpriteInfo/SpriteInfoStatTableView.tscn",
}


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	if not _assert_source_boundaries():
		return

	var packed := load(PANEL_SCENE_PATH) as PackedScene
	if packed == null:
		_fail("Sprite info panel scene cannot be loaded")
		return

	var panel := packed.instantiate() as SpriteInfoPanel
	root.add_child(panel)
	await process_frame
	await process_frame

	for node_path in COMPONENT_PATHS:
		var component := panel.get_node_or_null(NodePath(node_path))
		if component == null:
			_fail("Missing authored sprite info component: %s" % node_path)
			return
		if component.scene_file_path != COMPONENT_PATHS[node_path]:
			_fail("Sprite info component is embedded instead of instanced: %s" % node_path)
			return

	var info := _make_info()
	panel.display_info(info)
	await process_frame

	var name_label := panel.get_node("PanelBackground/ContentMargin/Layout/SpriteInfoHeaderView/NameLabel") as Label
	if name_label.text != "测试宠物":
		_fail("Sprite info header did not refresh through its component API")
		return

	var attack_view := panel.get_node("PanelBackground/ContentMargin/Layout/SpriteInfoAttackPatternView") as SpriteInfoAttackPatternView
	if attack_view.get_cell_count() != 21:
		_fail("Attack pattern must keep exactly 21 reusable cell prefabs")
		return

	var attack_value := panel.get_node("PanelBackground/ContentMargin/Layout/SpriteInfoStatTableView/StatsMargin/StatsRows/AttackRow/ValueLabel") as Label
	if attack_value.text != "123456789":
		_fail("Sprite info stat component did not render the supplied value")
		return
	if attack_value.get_theme_font_size("font_size") >= 24:
		_fail("Long stat values did not use the compact font size")
		return

	var attack_cells := attack_view.get_node("AttackMargin/AttackLayout/AttackCells") as GridContainer
	for index in 10:
		info.origin_cell_index = index
		panel.display_info(info)
		await process_frame
		if attack_cells.get_child_count() != 21:
			_fail("Repeated refresh changed the attack cell count")
			return

	panel.display_info(null)
	if panel.visible:
		_fail("Null sprite info must hide the panel")
		return
	panel.display_info(info)
	if not panel.visible:
		_fail("Valid sprite info must restore the panel after a null value")
		return

	panel.free()
	print("SPRITE_INFO_PANEL_PREFAB_OK cells=21 refreshes=10")
	quit()


func _make_info() -> SpriteInfoData:
	var rank := SpriteRankStats.new()
	rank.quality_name = "钻石"
	rank.hp_current = 9999
	rank.hp_max = 9999
	rank.ap_current = 12
	rank.ap_max = 12
	rank.attack = 123456789
	rank.defense = 2345
	rank.shield = 3456
	rank.regen = 4567

	var info := SpriteInfoData.new()
	info.sprite_id = "test_pet"
	info.display_name = "测试宠物"
	info.element_name = "水属性"
	info.origin_cell_index = 10
	info.hit_cell_indices = [3, 9, 11, 17]
	info.ranks = [rank]
	return info


func _assert_source_boundaries() -> bool:
	var panel_source := _read_source(PANEL_SCRIPT_PATH)
	for fragment in ["Control.new()", "Label.new()", "TextureRect.new()", "PanelContainer.new()", "add_child("]:
		if panel_source.contains(fragment):
			_fail("SpriteInfoPanel root script still constructs authored UI: %s" % fragment)
			return false

	var battle_source := _read_source(BATTLE_UNIT_SCRIPT_PATH)
	if battle_source.contains(".call(\""):
		_fail("BattleUnit still uses string-based calls for internal components")
		return false
	return true


func _read_source(path: String) -> String:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return ""
	return file.get_as_text()


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
