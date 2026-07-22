@tool
extends Control

signal screen_requested(screen_id: StringName, view_model: Dictionary)

const BOARD_COLUMNS := 8
const BOARD_ROWS := 7
const BOARD_SIZE := Vector2(1120.0, 880.0)
const CELL_GAP := Vector2(8.0, 8.0)
const CELL_BORDER_WIDTH := 3
const CELL_CORNER_RADIUS := 10
const CELL_SHADOW_SIZE := 4
const CELL_SHADOW_OFFSET := Vector2(0.0, 3.0)
const CELL_OUTLINE_BACKGROUND := Color(0.82, 0.84, 0.86, 0.02)
const CELL_OUTLINE_COLOR := Color(0.86, 0.89, 0.91, 0.34)
const CELL_OUTLINE_SHADOW := Color(0.13, 0.08, 0.03, 0.12)
const FILE_LABELS := "abcdefgh"
const CELL_SCENE := preload("res://Features/Battle/Prefabs/Board/BoardCell.tscn")
const PET_UNIT_SCENE := preload("res://Features/Battle/Prefabs/Units/BattleUnit/BattleUnit.tscn")
const DATA_PROVIDER_SCRIPT := preload("res://PreviewData/Providers/GameDataProvider.gd")
const SESSION_STORE_SCRIPT := preload("res://PreviewData/State/GameSessionStore.gd")
const CLOCK_INDICATOR_SCENE := preload("res://Features/Battle/Prefabs/HUD/ClockIndicator/ClockIndicator.tscn")
const ROUND_BANNER_SCENE := preload("res://Features/Battle/Prefabs/HUD/RoundBanner/RoundBanner.tscn")
const MONSTER_BITE_SCENE := preload("res://Features/Battle/Prefabs/Effects/MonsterBite/MonsterBiteEffect.tscn")
const DAMAGE_NUMBER_SCENE := preload("res://Features/Battle/Prefabs/Effects/DamageNumber/DamageNumber.tscn")
const ELEMENT_BULLET_SCENE := preload("res://Features/Battle/Prefabs/Effects/ElementBullet/ElementBullet.tscn")

const FIRE_SPRITE := preload("res://Features/Battle/Art/Units/Sprite_FlameCub.png")
const WATER_SPRITE := preload("res://Features/Battle/Art/Units/Sprite_WaterWisp.png")
const FIRE_BULLET := preload("res://Features/Battle/Art/Combat/Projectiles/fire_bullet.png")
const WATER_BULLET := preload("res://Features/Battle/Art/Combat/Projectiles/water_bullet.png")
const EARTH_BULLET := preload("res://Features/Battle/Art/Combat/Projectiles/earth_bullet.png")
const WIND_BULLET := preload("res://Features/Battle/Art/Combat/Projectiles/wind_bullet.png")
const FIRE_BUFF := preload("res://Features/Battle/Art/Combat/ElementBuffs/elemental-sigil-fire.png")
const WATER_BUFF := preload("res://Features/Battle/Art/Combat/ElementBuffs/elemental-sigil-water.png")
const EARTH_BUFF := preload("res://Features/Battle/Art/Combat/ElementBuffs/elemental-sigil-earth.png")
const WIND_BUFF := preload("res://Features/Battle/Art/Combat/ElementBuffs/elemental-sigil-wind.png")
const PLAYER_HEALTH_ICON := preload("res://Features/Battle/Art/UI/health-icon-green.png")
const ENEMY_HEALTH_ICON := preload("res://Features/Battle/Art/UI/health-icon.png")
const ATTACK_ICON := preload("res://Features/Battle/Art/UI/attack-icon.png")
const PLAYER_DEATH_MARK := preload("res://Features/Battle/Art/Combat/DeathMarks/death_mark_player.png")
const ENEMY_DEATH_MARK := preload("res://Features/Battle/Art/Combat/DeathMarks/death_mark_enemy.png")
const HOVER_FRAME := preload("res://Features/Battle/Art/Units/tile_hover_frame_ai_512.png")
const SCREEN_IDS := preload("res://Shared/Navigation/ScreenIds.gd")
const RETURN_FROM_BATTLE_META := &"returning_from_battle"
const MONSTER_BITE_FRAME_01 := preload("res://Features/Battle/Art/Combat/MonsterBite/monster_teeth_bite_01.png")
const ATTACK_ORDER_MARKER_1 := preload("res://Features/Battle/Art/Combat/AttackOrder/dice_marker_1.png")
const ATTACK_ORDER_MARKER_2 := preload("res://Features/Battle/Art/Combat/AttackOrder/dice_marker_2.png")
const ATTACK_ORDER_MARKER_3 := preload("res://Features/Battle/Art/Combat/AttackOrder/dice_marker_3.png")

const TEAM_PLAYER := "player"
const TEAM_ENEMY := "enemy"
const PHASE_DEPLOY := "deploy"
const PHASE_ACTION := "action"
const HIGHLIGHT_DEPLOY := "deploy"
const HIGHLIGHT_ATTACK_PREVIEW := "attack_preview"
const HIGHLIGHT_ATTACK_LOCKED := "attack_locked"
const ATTACK_ORDER_MARKER_SIZE := Vector2(34.0, 34.0)
const HOVER_FRAME_SCALE := 1.0
const HEALTH_ICON_REGION := Rect2(267.0, 83.0, 734.0, 891.0)
const ATTACK_ICON_REGION := Rect2(138.0, 132.0, 950.0, 978.0)
const STAT_ORB_RADIUS := 20.0
const STAT_ORB_RADIUS_TO_BADGE_HEIGHT := 0.39
const STAT_ORB_CORNER_OVERLAP := 6.0
const UNIT_VISIBLE_TOP_RATIO := -0.15
const UNIT_VISIBLE_BOTTOM_RATIO := 0.86
const UNIT_SHADOW_BASE_SIZE := Vector2(384.0, 96.0)
const UNIT_SHADOW_WIDTH_RATIO := 0.72
const UNIT_SHADOW_CENTER_Y_OFFSET := -5.0
const HEALTH_NUMBER_CENTER := Vector2(0.5, 0.62)
const ATTACK_NUMBER_CENTER := Vector2(0.57, 0.59)
const STAT_NUMBER_COLOR := Color.WHITE
const STAT_NUMBER_PREVIEW_COLOR := Color(1.0, 0.22, 0.14)
const ACTION_STEP_DELAY := 0.16
const BULLET_FLIGHT_DURATION := 0.32
const BULLET_ARC_MIN_HEIGHT := 72.0
const BULLET_ARC_DISTANCE_SCALE := 0.32
const HERO_BARRAGE_SHOT_INTERVAL := 0.055
const HERO_BARRAGE_VOLLEY_DELAY := 0.12
const ENEMY_MOVE_DURATION := 0.22
const ENEMY_ATTACK_LEAP_IN_DURATION := 0.18
const ENEMY_ATTACK_LEAP_OUT_DURATION := 0.16
const ENEMY_ATTACK_LEAP_HEIGHT := 42.0
const MONSTER_BITE_SCALE := 1.55
const ROUND_BANNER_HOLD_DURATION := 1.0
const CLOCK_POSITION := Vector2(22.0, 519.0)
const CLOCK_SIZE := 155.0
const CLOCK_HOURS_PER_DAY := 6
const QUICK_TEST_CHEAT_SEQUENCE := [
	KEY_UP,
	KEY_UP,
	KEY_DOWN,
	KEY_DOWN,
	KEY_LEFT,
	KEY_RIGHT,
	KEY_LEFT,
	KEY_RIGHT,
	KEY_B,
	KEY_A,
]
const QUICK_TEST_CHEAT_ATTACK_BONUS := 100
const QUICK_TEST_CHEAT_HP_BONUS := 100

var _cell_size := Vector2.ZERO
var _cells := {}
var _units: Array[Dictionary] = []
var _traps := {}
var _highlighted_cells := {}
var _attack_order_markers := {}
var _phase := PHASE_DEPLOY
var _hover_frame: TextureRect
var _hovered_grid := Vector2i(-1, -1)
var _selected_unit: Dictionary = {}
var _dragged_unit: Dictionary = {}
var _drag_origin_grid := Vector2i(-1, -1)
var _drag_offset := Vector2.ZERO
var _death_preview_marks_enabled := false
var _begin_turn_button: TextureButton
var _auto_arrange_button: TextureButton
var _round_number := 1
var _is_round_banner_showing := false
var _quick_test_cheat_index := 0
var _battle_return_started := false
var _clock_root: Node2D = null
var _clock_total_hours := 0
var _clock_hour := 0
var _clock_day := 1
var _data_provider = DATA_PROVIDER_SCRIPT.new()
var _session_store = SESSION_STORE_SCRIPT.new()
var _battle_data: Dictionary = {}
var _battle_defaults: Dictionary = {}
var _player_attack_directions: Array[Vector2i] = []
var _player_attack_distances: Array[int] = []


func _ready() -> void:
	_load_battle_data()
	mouse_filter = Control.MOUSE_FILTER_STOP
	custom_minimum_size = BOARD_SIZE
	size = BOARD_SIZE
	# The board is assembled from code. Running this part as a tool script keeps
	# the complete battle layout visible while the scene is open in the editor.
	# Save data, input hooks and turn animations remain runtime-only below.
	if not Engine.is_editor_hint():
		_load_clock_state()
	_build_board()
	_prepare_clock_indicator()
	if Engine.is_editor_hint():
		_refresh_deploy_highlights()
		set_process(false)
		set_process_input(false)
		return

	_connect_scene_buttons()
	_begin_deploy_phase.call_deferred(true)


func _load_battle_data() -> void:
	_battle_data = _data_provider.get_battle_data()
	_battle_defaults = _battle_data.get("defaults", {}) as Dictionary
	_player_attack_directions.clear()
	for direction in _battle_data.get("player_attack_directions", []):
		_player_attack_directions.append(Vector2i(direction))
	_player_attack_distances.clear()
	for distance in _battle_data.get("player_attack_distances", []):
		_player_attack_distances.append(int(distance))


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	_update_hover_frame()
	_update_dragged_unit_position()


func _input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
	if event is InputEventKey and event.pressed and not event.echo:
		var keycode: int = event.keycode
		if keycode == KEY_NONE:
			keycode = event.physical_keycode
		_handle_quick_test_cheat_key(keycode)

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		if not _dragged_unit.is_empty():
			_finish_drag()
			accept_event()


func _handle_quick_test_cheat_key(keycode: int) -> void:
	if keycode == int(QUICK_TEST_CHEAT_SEQUENCE[_quick_test_cheat_index]):
		_quick_test_cheat_index += 1
		if _quick_test_cheat_index >= QUICK_TEST_CHEAT_SEQUENCE.size():
			_quick_test_cheat_index = 0
			_apply_quick_test_cheat()
		return

	_quick_test_cheat_index = 1 if keycode == int(QUICK_TEST_CHEAT_SEQUENCE[0]) else 0


func _apply_quick_test_cheat() -> void:
	for unit in _units:
		if unit["team"] != TEAM_PLAYER or bool(unit.get("is_hero", false)):
			continue

		unit["attack_damage"] = int(unit["attack_damage"]) + QUICK_TEST_CHEAT_ATTACK_BONUS
		unit["max_hp"] = int(unit.get("max_hp", unit["hp"])) + QUICK_TEST_CHEAT_HP_BONUS
		unit["hp"] = int(unit["hp"]) + QUICK_TEST_CHEAT_HP_BONUS
		_update_unit_visual(unit)

	_refresh_damage_previews({}, Vector2i(-1, -1), false)


func _connect_scene_buttons() -> void:
	var auto_button := get_parent().get_node_or_null("AutoArrangeButton") as TextureButton
	if auto_button != null:
		_auto_arrange_button = auto_button
		_auto_arrange_button.pressed.connect(_on_auto_arrange_pressed)

	var button := get_parent().get_node_or_null("BeginTurnButton") as TextureButton
	if button != null:
		_begin_turn_button = button
		_begin_turn_button.pressed.connect(_on_begin_turn_pressed)


func _prepare_clock_indicator() -> void:
	var scene_root := get_parent() as Control
	if scene_root == null:
		push_warning("Clock indicator cannot find scene root.")
		return

	_clock_root = CLOCK_INDICATOR_SCENE.instantiate() as Node2D
	if _clock_root == null:
		push_warning("Clock indicator prefab could not be instantiated.")
		return
	_clock_root.position = CLOCK_POSITION
	_clock_root.z_index = 20
	scene_root.add_child.call_deferred(_clock_root)
	_clock_root.call("setup", _clock_total_hours, CLOCK_SIZE, false)


func _set_clock_total_hours(total_hours: int) -> void:
	_clock_total_hours = max(0, total_hours)
	_clock_hour = _clock_total_hours % CLOCK_HOURS_PER_DAY
	_clock_day = int(_clock_total_hours / CLOCK_HOURS_PER_DAY) + 1


func _load_clock_state() -> void:
	_set_clock_total_hours(_session_store.load_clock_total_hours(0))


func _update_clock_display() -> void:
	if _clock_root == null:
		return
	_clock_root.call("set_total_hours", _clock_total_hours, false)


func _build_board() -> void:
	for child in get_children():
		child.queue_free()

	_cells.clear()
	_units.clear()
	_traps.clear()
	_highlighted_cells.clear()
	_attack_order_markers.clear()
	_phase = PHASE_DEPLOY
	_hover_frame = null
	_hovered_grid = Vector2i(-1, -1)
	_selected_unit = {}
	_dragged_unit = {}
	_drag_origin_grid = Vector2i(-1, -1)
	_drag_offset = Vector2.ZERO

	_cell_size = Vector2(
		(BOARD_SIZE.x - CELL_GAP.x * float(BOARD_COLUMNS - 1)) / float(BOARD_COLUMNS),
		(BOARD_SIZE.y - CELL_GAP.y * float(BOARD_ROWS - 1)) / float(BOARD_ROWS)
	)

	for row in BOARD_ROWS:
		for column in BOARD_COLUMNS:
			var grid := Vector2i(column, row)
			var cell := CELL_SCENE.instantiate() as Panel
			add_child(cell)
			cell.name = "Cell_%s%d" % [_file_label(column), row + 1]
			cell.position = _cell_origin(grid)
			cell.size = _cell_size
			cell.mouse_filter = Control.MOUSE_FILTER_STOP
			cell.add_theme_stylebox_override("panel", _make_cell_style(""))
			cell.gui_input.connect(_on_cell_gui_input.bind(grid))
			_cells[_grid_key(grid)] = cell

	for unit_data in _data_provider.get_battle_units():
		_add_unit(unit_data)

	_create_hover_frame()


func _create_hover_frame() -> void:
	var frame := TextureRect.new()
	add_child(frame)
	frame.name = "HoverFrame"
	frame.texture = HOVER_FRAME
	frame.size = _cell_size * HOVER_FRAME_SCALE
	frame.custom_minimum_size = Vector2.ZERO
	frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.stretch_mode = TextureRect.STRETCH_SCALE
	frame.z_index = 18
	frame.visible = false
	_hover_frame = frame


func _update_hover_frame() -> void:
	if not is_instance_valid(_hover_frame):
		return

	var grid := _position_to_board_index(get_local_mouse_position())
	if not _is_inside_board(grid):
		_hovered_grid = Vector2i(-1, -1)
		_hover_frame.visible = false
		return

	var frame_size := _cell_size * HOVER_FRAME_SCALE
	_hovered_grid = grid
	_hover_frame.size = frame_size
	_hover_frame.position = _cell_origin(grid) - (frame_size - _cell_size) * 0.5
	_hover_frame.visible = _phase == PHASE_DEPLOY and not _is_round_banner_showing


func _stat_badge_presentation(
	source_texture: Texture2D,
	region: Rect2,
	place_at_top: bool,
	number_center: Vector2
) -> Dictionary:
	var cropped_texture := AtlasTexture.new()
	cropped_texture.atlas = source_texture
	cropped_texture.region = region

	var badge_height := STAT_ORB_RADIUS / STAT_ORB_RADIUS_TO_BADGE_HEIGHT
	var badge_size := Vector2(badge_height * region.size.x / region.size.y, badge_height)
	var corner_offset := STAT_ORB_RADIUS - STAT_ORB_CORNER_OVERLAP
	var orb_center := Vector2(corner_offset, corner_offset)
	if not place_at_top:
		orb_center.y = _cell_size.y - corner_offset
	var icon_position := orb_center - badge_size * number_center
	var label_width_ratio := 1.58 if place_at_top else 1.24
	var label_size := Vector2(badge_height * label_width_ratio, badge_height * 0.94)
	var label_center := icon_position + badge_size * number_center
	return {
		"texture": cropped_texture,
		"icon_position": icon_position,
		"icon_size": badge_size,
		"label_position": label_center - label_size * 0.5,
		"label_size": label_size,
	}


func _add_unit(unit_data: Dictionary) -> void:
	var coord := String(unit_data["coord"])
	var team := String(unit_data["team"])
	var board_index := _coord_to_board_index(coord)
	if not _is_inside_board(board_index):
		return

	var unit_node := PET_UNIT_SCENE.instantiate() as Control
	add_child(unit_node)
	unit_node.name = "Unit_%s_%s" % [String(unit_data["team"]), coord]
	unit_node.position = _cell_origin(board_index)
	unit_node.size = _cell_size
	unit_node.clip_contents = false

	var shadow_scale := _cell_size.x * UNIT_SHADOW_WIDTH_RATIO / UNIT_SHADOW_BASE_SIZE.x
	var shadow_size := UNIT_SHADOW_BASE_SIZE * shadow_scale
	var shadow_position := Vector2(
		(_cell_size.x - shadow_size.x) * 0.5,
		_cell_size.y * UNIT_VISIBLE_BOTTOM_RATIO - shadow_size.y * 0.5 + UNIT_SHADOW_CENTER_Y_OFFSET
	)
	var sprite_texture := unit_data.get(
		"sprite", _texture_for_element(String(unit_data["element"]))
	) as Texture2D
	var sprite_layout := _sprite_layout_for_cell(sprite_texture)
	var health_badge := _stat_badge_presentation(
		PLAYER_HEALTH_ICON if team == TEAM_PLAYER else ENEMY_HEALTH_ICON,
		HEALTH_ICON_REGION,
		true,
		HEALTH_NUMBER_CENTER
	)
	var attack_badge := _stat_badge_presentation(
		ATTACK_ICON,
		ATTACK_ICON_REGION,
		false,
		ATTACK_NUMBER_CENTER
	)

	var default_max_hp := int(_battle_defaults.get("player_max_hp", 10)) if team == TEAM_PLAYER else int(_battle_defaults.get("enemy_max_hp", 5))
	var max_hp := int(unit_data.get("max_hp", unit_data.get("hp", default_max_hp)))
	var resolved_data := unit_data.duplicate(true)
	resolved_data["hp"] = int(unit_data.get("hp", max_hp))
	resolved_data["attack_damage"] = int(unit_data.get("attack_damage", int(_battle_defaults.get("player_attack_damage", 5)) if team == TEAM_PLAYER else int(_battle_defaults.get("enemy_attack_damage", 1))))
	unit_node.call("set_battle_data", resolved_data, {
		"cell_size": _cell_size,
		"shadow_size": shadow_size,
		"shadow_position": shadow_position,
		"shadow_scale": Vector2.ONE * shadow_scale,
		"sprite_texture": sprite_texture,
		"sprite_position": sprite_layout["position"],
		"sprite_scale": Vector2.ONE * float(sprite_layout["scale"]),
		"pixel_art": bool(unit_data.get("pixel_art", false)),
		"health": health_badge,
		"attack": attack_badge,
		"death_mark_texture": _death_mark_texture_for_unit(team),
		"death_mark_scale": _death_mark_preview_scale(_death_mark_texture_for_unit(team)),
	})
	unit_node.z_index = 10
	unit_node.mouse_filter = Control.MOUSE_FILTER_STOP
	var shadow := unit_node.get_node("UnitShadow") as Control
	var sprite := unit_node.get_node("Sprite") as Sprite2D
	var health_icon := unit_node.get_node("HealthIcon") as TextureRect
	var hp_label := unit_node.get_node("HpLabel") as Label
	var attack_icon := unit_node.get_node("AttackIcon") as TextureRect
	var attack_label := unit_node.get_node("AttackLabel") as Label
	var damage_preview_label := unit_node.get_node("DamagePreviewLabel") as Label
	var death_mark := unit_node.get_node("DeathMarkPreview") as Sprite2D
	var unit := {
		"node": unit_node,
		"shadow": shadow,
		"sprite": sprite,
		"health_icon": health_icon,
		"hp_label": hp_label,
		"attack_icon": attack_icon,
		"attack_label": attack_label,
		"damage_preview_label": damage_preview_label,
		"death_mark": death_mark,
		"team": team,
		"element": String(unit_data["element"]),
		"grid": board_index,
		"hp": int(resolved_data["hp"]),
		"max_hp": max_hp,
		"attack_damage": int(resolved_data["attack_damage"]),
		"move_distance": int(unit_data.get("move_distance", int(_battle_defaults.get("enemy_move_distance", 1)))),
		"movable": bool(unit_data.get("movable", true)),
		"is_hero": bool(unit_data.get("is_hero", false)),
	}
	_units.append(unit)
	unit_node.gui_input.connect(_on_unit_gui_input.bind(unit_node))
	_update_unit_visual(unit)


func _begin_deploy_phase(show_round_banner: bool = false) -> void:
	_phase = PHASE_DEPLOY
	_clear_selected_unit()
	_dragged_unit = {}
	_drag_origin_grid = Vector2i(-1, -1)
	_death_preview_marks_enabled = false
	_set_begin_button_disabled(true)
	_set_auto_arrange_button_disabled(true)
	_refresh_deploy_highlights()
	if show_round_banner:
		await _show_round_banner(_round_number)
	if _phase != PHASE_DEPLOY:
		return
	_set_begin_button_disabled(false)
	_set_auto_arrange_button_disabled(false)


func _show_round_banner(round_number: int) -> void:
	_is_round_banner_showing = true
	if is_instance_valid(_hover_frame):
		_hover_frame.visible = false

	var scene_root := get_parent() as Control
	if scene_root == null:
		await get_tree().create_timer(ROUND_BANNER_HOLD_DURATION).timeout
		_is_round_banner_showing = false
		return

	var overlay := ROUND_BANNER_SCENE.instantiate() as Control
	if overlay == null:
		await get_tree().create_timer(ROUND_BANNER_HOLD_DURATION).timeout
		_is_round_banner_showing = false
		return
	scene_root.add_child(overlay)
	overlay.call("setup", round_number, "我方回合")
	overlay.call("play")
	await overlay.tree_exited
	_is_round_banner_showing = false


func _on_unit_gui_input(event: InputEvent, unit_node: Control) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if _phase != PHASE_DEPLOY or _is_round_banner_showing:
			return

		var unit := _find_unit_by_node(unit_node)
		if unit.is_empty():
			return
		if unit["team"] != TEAM_PLAYER:
			_clear_selected_unit()
			_refresh_deploy_highlights()
			return
		if not _is_unit_movable(unit):
			_clear_selected_unit()
			_refresh_deploy_highlights()
			return

		_start_drag(unit)
		accept_event()


func _on_cell_gui_input(event: InputEvent, grid: Vector2i) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if _phase != PHASE_DEPLOY or _is_round_banner_showing:
			return

		if _selected_unit.is_empty():
			return

		if _try_move_selected_unit_to(grid):
			accept_event()


func _start_drag(unit: Dictionary) -> void:
	if not _is_unit_movable(unit):
		return

	_select_unit(unit)
	_dragged_unit = unit
	_drag_origin_grid = Vector2i(unit["grid"])
	_drag_offset = get_local_mouse_position() - _cell_origin(_drag_origin_grid)
	_death_preview_marks_enabled = true
	_set_unit_dragging_visual(unit, true)
	_show_drag_highlights(_drag_origin_grid)


func _update_dragged_unit_position() -> void:
	if _dragged_unit.is_empty():
		return

	var node := _dragged_unit["node"] as Control
	if not is_instance_valid(node):
		return

	node.position = get_local_mouse_position() - _drag_offset
	var target_grid := _position_to_board_index(get_local_mouse_position())
	_show_drag_highlights(target_grid)


func _finish_drag() -> void:
	var target_grid := _position_to_board_index(get_local_mouse_position())
	var unit := _dragged_unit
	if unit.is_empty():
		return

	if _can_place_player_at(target_grid, unit):
		_move_unit_to(unit, target_grid)
	else:
		_move_unit_to(unit, _drag_origin_grid)

	_set_unit_dragging_visual(unit, false)
	_select_unit(unit)
	_dragged_unit = {}
	_drag_origin_grid = Vector2i(-1, -1)
	_refresh_deploy_highlights()


func _try_move_selected_unit_to(target_grid: Vector2i) -> bool:
	if _selected_unit.is_empty() or not _is_unit_active(_selected_unit):
		_clear_selected_unit()
		_refresh_deploy_highlights()
		return false
	if not _is_unit_movable(_selected_unit):
		_clear_selected_unit()
		_refresh_deploy_highlights()
		return false

	if not _can_place_player_at(target_grid, _selected_unit):
		return false

	_death_preview_marks_enabled = true
	_move_unit_to(_selected_unit, target_grid)
	_select_unit(_selected_unit)
	_refresh_deploy_highlights()
	return true


func _select_unit(unit: Dictionary) -> void:
	if unit.is_empty() or not _is_unit_active(unit):
		_clear_selected_unit()
		return

	if not _selected_unit.is_empty() and _selected_unit != unit and _is_unit_active(_selected_unit):
		_apply_unit_frame_style(_selected_unit, false)

	_selected_unit = unit
	_apply_unit_frame_style(_selected_unit, true)


func _clear_selected_unit() -> void:
	if not _selected_unit.is_empty() and _is_unit_active(_selected_unit):
		_apply_unit_frame_style(_selected_unit, false)
	_selected_unit = {}


func _show_drag_highlights(target_grid: Vector2i) -> void:
	_clear_highlights()
	_show_placeable_cells(_dragged_unit)
	if _can_place_player_at(target_grid, _dragged_unit):
		_show_attack_cells_for_position(target_grid, HIGHLIGHT_ATTACK_PREVIEW)
		_refresh_damage_previews(_dragged_unit, target_grid, true)
	else:
		_refresh_damage_previews({}, Vector2i(-1, -1), false)


func _refresh_deploy_highlights() -> void:
	_clear_highlights()
	_show_placeable_cells({})
	for unit in _units:
		if unit["team"] == TEAM_PLAYER and _is_unit_movable(unit):
			_show_attack_cells_for_position(Vector2i(unit["grid"]), HIGHLIGHT_ATTACK_LOCKED)
	_refresh_damage_previews({}, Vector2i(-1, -1), false)


func _show_placeable_cells(ignore_unit: Dictionary) -> void:
	for row in BOARD_ROWS:
		for column in BOARD_COLUMNS:
			var grid := Vector2i(column, row)
			if _can_place_player_at(grid, ignore_unit):
				_set_cell_highlight(grid, HIGHLIGHT_DEPLOY)


func _show_attack_cells_for_position(origin: Vector2i, highlight_mode: String) -> void:
	for direction_index in _player_attack_directions.size():
		var direction := _player_attack_directions[direction_index]
		var direction_cells := _player_attack_cells_for_direction(origin, direction)
		for grid in direction_cells:
			_set_cell_highlight(grid, highlight_mode)
		if not direction_cells.is_empty():
			_set_attack_order_marker(direction_cells[direction_cells.size() - 1], direction_index + 1)


func _clear_highlights() -> void:
	_clear_attack_order_markers()
	for key in _highlighted_cells.keys():
		if _cells.has(key):
			var cell := _cells[key] as Panel
			cell.add_theme_stylebox_override("panel", _make_cell_style(""))
	_highlighted_cells.clear()


func _set_cell_highlight(grid: Vector2i, highlight_mode: String) -> void:
	if not _is_inside_board(grid):
		return

	var key := _grid_key(grid)
	if not _cells.has(key):
		return

	var cell := _cells[key] as Panel
	cell.add_theme_stylebox_override("panel", _make_cell_style(highlight_mode))
	_highlighted_cells[key] = highlight_mode


func _set_attack_order_marker(grid: Vector2i, dot_count: int) -> void:
	if not _is_inside_board(grid):
		return

	var key := _grid_key(grid)
	if _attack_order_markers.has(key) or not _cells.has(key):
		return

	var texture := _attack_order_marker_texture(dot_count)
	if texture == null:
		return

	var marker := TextureRect.new()
	var marker_size := ATTACK_ORDER_MARKER_SIZE
	var cell := _cells[key] as Panel
	cell.add_child(marker)
	marker.name = "AttackOrderMarker_%d" % dot_count
	marker.texture = texture
	marker.size = marker_size
	marker.position = (_cell_size - marker_size) * 0.5
	marker.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	marker.stretch_mode = TextureRect.STRETCH_SCALE
	marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	marker.z_index = 6

	_attack_order_markers[key] = marker


func _clear_attack_order_markers() -> void:
	for marker in _attack_order_markers.values():
		if is_instance_valid(marker):
			marker.queue_free()
	_attack_order_markers.clear()


func _attack_order_marker_texture(dot_count: int) -> Texture2D:
	match dot_count:
		1:
			return ATTACK_ORDER_MARKER_1
		2:
			return ATTACK_ORDER_MARKER_2
		3:
			return ATTACK_ORDER_MARKER_3
		_:
			return null


func _on_begin_turn_pressed() -> void:
	if _phase != PHASE_DEPLOY or _is_round_banner_showing:
		return
	_run_player_action.call_deferred()


func _on_auto_arrange_pressed() -> void:
	if _phase != PHASE_DEPLOY or _is_round_banner_showing:
		return

	if not _dragged_unit.is_empty():
		_move_unit_to(_dragged_unit, _drag_origin_grid)
		_apply_unit_frame_style(_dragged_unit, false)
		_set_unit_dragging_visual(_dragged_unit, false)
		_dragged_unit = {}
		_drag_origin_grid = Vector2i(-1, -1)
		if not _selected_unit.is_empty():
			_select_unit(_selected_unit)

	var arrangement := _find_best_auto_arrangement()
	if arrangement.is_empty():
		return

	_death_preview_marks_enabled = true
	var positions: Dictionary = arrangement["positions"]
	for unit in _units:
		if unit["team"] != TEAM_PLAYER:
			continue

		var source_id := _unit_source_id(unit)
		if positions.has(source_id):
			_move_unit_to(unit, Vector2i(positions[source_id]))

	_refresh_deploy_highlights()


func _run_player_action() -> void:
	_phase = PHASE_ACTION
	_set_begin_button_disabled(true)
	_set_auto_arrange_button_disabled(true)
	_clear_selected_unit()
	_clear_highlights()
	_clear_damage_previews()
	if is_instance_valid(_hover_frame):
		_hover_frame.visible = false

	for unit in _units.duplicate():
		if not _is_unit_active(unit) or unit["team"] != TEAM_PLAYER:
			continue

		_apply_unit_frame_style(unit, true)
		for direction in _player_attack_directions:
			await _resolve_player_attack_direction(unit, direction)
			if _find_enemy_hero().is_empty():
				_apply_unit_frame_style(unit, false)
				return
		_apply_unit_frame_style(unit, false)

	if _should_trigger_enemy_hero_barrage():
		await _run_enemy_hero_barrage()
		if _find_enemy_hero().is_empty():
			return

	await _run_enemy_action()
	if _find_enemy_hero().is_empty():
		return
	await get_tree().create_timer(0.2).timeout
	_round_number += 1
	await _begin_deploy_phase(true)


func _run_enemy_action() -> void:
	for unit in _units.duplicate():
		if not _is_unit_active(unit) or unit["team"] != TEAM_ENEMY:
			continue

		var target := _find_enemy_attack_target(unit)
		if target.is_empty():
			await _move_enemy_toward_player(unit)
			if not _is_unit_active(unit):
				if _should_trigger_enemy_hero_barrage():
					await _run_enemy_hero_barrage()
					if _find_enemy_hero().is_empty():
						return
				await get_tree().create_timer(ACTION_STEP_DELAY).timeout
				continue
			target = _find_enemy_attack_target(unit)

		if not target.is_empty():
			await _resolve_enemy_attack(unit, target)

		await get_tree().create_timer(ACTION_STEP_DELAY).timeout


func _resolve_enemy_attack(attacker: Dictionary, target: Dictionary) -> void:
	if not _is_unit_active(attacker) or not _is_unit_active(target):
		return
	if int(attacker["attack_damage"]) <= 0:
		return

	var attacker_node := attacker["node"] as Control
	var original_position := attacker_node.position
	var original_z_index := attacker_node.z_index
	var original_scale := attacker_node.scale
	var original_pivot := attacker_node.pivot_offset
	var target_grid := Vector2i(target["grid"])
	var attack_position := _cell_origin(target_grid)

	attacker_node.z_index = 50
	attacker_node.pivot_offset = _cell_size * 0.5
	await _hop_unit_visual_to(attacker, attack_position, ENEMY_ATTACK_LEAP_IN_DURATION, ENEMY_ATTACK_LEAP_HEIGHT, original_scale)

	await _play_monster_bite_attack(target_grid, func() -> void:
		if _is_unit_active(target):
			_damage_unit(target, int(attacker["attack_damage"]))
			if _is_unit_active(target):
				_shake_unit_visual(target)
	)

	if _is_unit_active(attacker):
		await _hop_unit_visual_to(attacker, original_position, ENEMY_ATTACK_LEAP_OUT_DURATION, ENEMY_ATTACK_LEAP_HEIGHT * 0.72, original_scale)
		attacker_node.position = original_position
		attacker_node.scale = original_scale
		attacker_node.z_index = original_z_index
		attacker_node.pivot_offset = original_pivot


func _move_enemy_toward_player(enemy: Dictionary) -> void:
	if not _is_unit_active(enemy) or not _is_unit_movable(enemy):
		return

	var move_distance := int(enemy.get("move_distance", int(_battle_defaults.get("enemy_move_distance", 1))))
	for step in move_distance:
		if _find_enemy_attack_target(enemy).is_empty() == false:
			return

		var target_grid := _best_enemy_move_grid(enemy)
		if target_grid == Vector2i(enemy["grid"]):
			return

		await _slide_unit_to(enemy, target_grid, ENEMY_MOVE_DURATION)
		_trigger_trap_at_enemy_grid(enemy)
		if not _is_unit_active(enemy):
			return


func _resolve_player_attack_direction(attacker: Dictionary, direction: Vector2i) -> void:
	if not _is_unit_active(attacker):
		return
	if int(attacker["attack_damage"]) <= 0:
		return

	var targets: Array[Dictionary] = []
	var trap_grids: Array[Vector2i] = []
	for grid in _player_attack_cells_for_direction(Vector2i(attacker["grid"]), direction):
		_shoot_bullet_to_grid(attacker, grid)
		var enemy := _find_enemy_at(grid)
		if not enemy.is_empty():
			targets.append(enemy)
		elif _find_unit_at(grid) == null:
			trap_grids.append(grid)

	await get_tree().create_timer(BULLET_FLIGHT_DURATION).timeout
	for target in targets:
		if _is_unit_active(target):
			_damage_unit(target, int(attacker["attack_damage"]))
	for grid in trap_grids:
		_place_trap(grid, String(attacker["element"]), int(attacker["attack_damage"]))

	await get_tree().create_timer(ACTION_STEP_DELAY).timeout


func _should_trigger_enemy_hero_barrage() -> bool:
	return not _find_enemy_hero().is_empty() and not _has_active_enemy_pieces()


func _run_enemy_hero_barrage() -> void:
	var hero := _find_enemy_hero()
	var volley_count := 0
	while _is_unit_active(hero) and volley_count < int(_battle_data.get("hero_barrage_max_volleys", 64)):
		var attackers := _active_player_attackers()
		if attackers.is_empty():
			return

		for shot_index in int(_battle_data.get("hero_barrage_bullets_per_attacker", 4)):
			for attacker in attackers:
				if _is_unit_active(attacker) and _is_unit_active(hero):
					_shoot_bullet_to_unit(attacker, hero, shot_index)
			await get_tree().create_timer(HERO_BARRAGE_SHOT_INTERVAL).timeout

		await get_tree().create_timer(BULLET_FLIGHT_DURATION).timeout
		for shot_index in int(_battle_data.get("hero_barrage_bullets_per_attacker", 4)):
			for attacker in attackers:
				if _is_unit_active(attacker) and _is_unit_active(hero):
					_damage_unit(hero, int(attacker["attack_damage"]))
		if _is_unit_active(hero):
			_shake_unit_visual(hero)
			await get_tree().create_timer(HERO_BARRAGE_VOLLEY_DELAY).timeout
		volley_count += 1


func _active_player_attackers() -> Array[Dictionary]:
	var attackers: Array[Dictionary] = []
	for unit in _units:
		if unit["team"] == TEAM_PLAYER and int(unit["attack_damage"]) > 0:
			attackers.append(unit)
	return attackers


func _player_attack_cells(origin: Vector2i) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for direction in _player_attack_directions:
		for grid in _player_attack_cells_for_direction(origin, direction):
			if not cells.has(grid):
				cells.append(grid)
	return cells


func _player_attack_cells_for_direction(origin: Vector2i, direction: Vector2i) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for distance in _player_attack_distances:
		var grid: Vector2i = origin + direction * int(distance)
		if _is_inside_board(grid):
			cells.append(grid)
	return cells


func _move_unit_to(unit: Dictionary, target_grid: Vector2i) -> void:
	unit["grid"] = target_grid
	var node := unit["node"] as Control
	node.position = _cell_origin(target_grid)


func _slide_unit_to(unit: Dictionary, target_grid: Vector2i, duration: float) -> void:
	unit["grid"] = target_grid
	var node := unit["node"] as Control
	var tween := create_tween()
	tween.tween_property(node, "position", _cell_origin(target_grid), duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished


func _hop_unit_visual_to(unit: Dictionary, target_position: Vector2, duration: float, hop_height: float, base_scale: Vector2) -> void:
	if not _is_unit_active(unit):
		return

	var node := unit["node"] as Control
	var start_position := node.position
	var tween := create_tween()
	tween.tween_method(
		Callable(self, "_set_unit_hop_progress").bind(node, start_position, target_position, hop_height, base_scale),
		0.0,
		1.0,
		duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished


func _set_unit_hop_progress(progress: float, node: Control, start_position: Vector2, target_position: Vector2, hop_height: float, base_scale: Vector2) -> void:
	if not is_instance_valid(node):
		return

	var arc_offset := Vector2.UP * sin(progress * PI) * hop_height
	var scale_boost := 1.0 + sin(progress * PI) * 0.08
	node.position = start_position.lerp(target_position, progress) + arc_offset
	node.scale = base_scale * scale_boost


func _play_monster_bite_attack(target_grid: Vector2i, hit_callback: Callable) -> void:
	var effect := MONSTER_BITE_SCENE.instantiate() as Sprite2D
	if effect == null:
		if hit_callback.is_valid():
			hit_callback.call()
		return
	add_child(effect)
	effect.position = _cell_center(target_grid) + Vector2(0.0, -6.0)
	effect.scale = _monster_bite_scale()
	effect.call("play", hit_callback)
	await effect.tree_exited


func _shake_unit_visual(unit: Dictionary) -> void:
	if not _is_unit_active(unit):
		return

	var node := unit["node"] as Control
	var origin := node.position
	var tween := create_tween()
	tween.tween_property(node, "position", origin + Vector2(8.0, -2.0), 0.035)
	tween.tween_property(node, "position", origin + Vector2(-6.0, 2.0), 0.04)
	tween.tween_property(node, "position", origin, 0.045)


func _can_place_player_at(grid: Vector2i, ignore_unit: Dictionary) -> bool:
	if not _is_inside_board(grid):
		return false
	if not ignore_unit.is_empty() and not _is_unit_movable(ignore_unit):
		return false

	var unit: Variant = _find_unit_at(grid)
	if unit == null:
		return true
	if not ignore_unit.is_empty() and unit == ignore_unit:
		return true
	return false


func _find_best_auto_arrangement() -> Dictionary:
	var player_units := _active_player_units()
	if player_units.is_empty():
		return {}

	var candidate_grids := _auto_arrange_candidate_grids()
	if candidate_grids.size() < player_units.size():
		return {}

	var search_state := {
		"best": {},
		"positions": {},
		"used": {},
	}
	_search_auto_arrangements(player_units, candidate_grids, 0, search_state)
	return search_state["best"]


func _search_auto_arrangements(player_units: Array[Dictionary], candidate_grids: Array[Vector2i], player_index: int, search_state: Dictionary) -> void:
	if player_index >= player_units.size():
		var positions: Dictionary = search_state["positions"]
		var score := _score_auto_arrangement(positions)
		var best: Dictionary = search_state["best"]
		if best.is_empty() or _is_auto_arrangement_score_better(score, best["score"]):
			search_state["best"] = {
				"positions": positions.duplicate(),
				"score": score,
			}
		return

	var unit := player_units[player_index]
	var source_id := _unit_source_id(unit)
	var positions: Dictionary = search_state["positions"]
	var used: Dictionary = search_state["used"]
	for grid in candidate_grids:
		var key := _grid_key(grid)
		if used.has(key):
			continue

		positions[source_id] = grid
		used[key] = true
		_search_auto_arrangements(player_units, candidate_grids, player_index + 1, search_state)
		positions.erase(source_id)
		used.erase(key)


func _score_auto_arrangement(positions: Dictionary) -> Dictionary:
	var preview := _calculate_turn_damage_preview_for_positions(positions)
	var dealt_damage: Dictionary = preview["dealt"]
	var incoming_damage: Dictionary = preview["incoming"]
	return {
		"dealt": _sum_damage(dealt_damage),
		"defeated_enemies": _count_defeated_enemies(dealt_damage),
		"incoming": _sum_damage(incoming_damage),
		"downed_players": _count_downed_players(incoming_damage),
		"movement": _total_auto_arrange_movement(positions),
		"position_key": _auto_arrange_position_key(positions),
	}


func _is_auto_arrangement_score_better(score: Dictionary, best_score: Dictionary) -> bool:
	if int(score["dealt"]) != int(best_score["dealt"]):
		return int(score["dealt"]) > int(best_score["dealt"])
	if int(score["incoming"]) != int(best_score["incoming"]):
		return int(score["incoming"]) < int(best_score["incoming"])
	if int(score["downed_players"]) != int(best_score["downed_players"]):
		return int(score["downed_players"]) < int(best_score["downed_players"])
	if int(score["defeated_enemies"]) != int(best_score["defeated_enemies"]):
		return int(score["defeated_enemies"]) > int(best_score["defeated_enemies"])
	if int(score["movement"]) != int(best_score["movement"]):
		return int(score["movement"]) < int(best_score["movement"])
	return String(score["position_key"]) < String(best_score["position_key"])


func _active_player_units() -> Array[Dictionary]:
	var player_units: Array[Dictionary] = []
	for unit in _units:
		if unit["team"] == TEAM_PLAYER and _is_unit_movable(unit):
			player_units.append(unit)
	return player_units


func _auto_arrange_candidate_grids() -> Array[Vector2i]:
	var grids: Array[Vector2i] = []
	for row in BOARD_ROWS:
		for column in BOARD_COLUMNS:
			var grid := Vector2i(column, row)
			if _can_auto_arrange_to(grid):
				grids.append(grid)
	return grids


func _can_auto_arrange_to(grid: Vector2i) -> bool:
	var unit: Variant = _find_unit_at(grid)
	if unit == null:
		return true
	var unit_data := unit as Dictionary
	return unit_data["team"] == TEAM_PLAYER and _is_unit_movable(unit_data)


func _sum_damage(damage_by_source: Dictionary) -> int:
	var total := 0
	for source_id in damage_by_source.keys():
		total += int(damage_by_source[source_id])
	return total


func _count_defeated_enemies(dealt_damage: Dictionary) -> int:
	var count := 0
	for unit in _units:
		if unit["team"] != TEAM_ENEMY:
			continue

		var source_id := _unit_source_id(unit)
		if int(dealt_damage.get(source_id, 0)) >= int(unit["hp"]):
			count += 1
	return count


func _count_downed_players(incoming_damage: Dictionary) -> int:
	var count := 0
	for unit in _units:
		if unit["team"] != TEAM_PLAYER:
			continue

		var source_id := _unit_source_id(unit)
		if int(incoming_damage.get(source_id, 0)) >= int(unit["hp"]):
			count += 1
	return count


func _total_auto_arrange_movement(positions: Dictionary) -> int:
	var total := 0
	for unit in _units:
		if unit["team"] != TEAM_PLAYER:
			continue

		var source_id := _unit_source_id(unit)
		if positions.has(source_id):
			total += _grid_distance(Vector2i(unit["grid"]), Vector2i(positions[source_id]))
	return total


func _auto_arrange_position_key(positions: Dictionary) -> String:
	var key := ""
	for unit in _units:
		if unit["team"] != TEAM_PLAYER:
			continue

		var source_id := _unit_source_id(unit)
		if positions.has(source_id):
			var grid := Vector2i(positions[source_id])
			key += "%02d:%02d;" % [grid.y, grid.x]
	return key


func _damage_unit(unit: Dictionary, amount: int) -> void:
	if not _is_unit_active(unit):
		return

	var damage_grid := Vector2i(unit["grid"])
	var defeated_enemy_hero := String(unit["team"]) == TEAM_ENEMY and bool(unit.get("is_hero", false))
	unit["hp"] = max(0, int(unit["hp"]) - amount)
	_update_unit_visual(unit)
	_show_damage_number(damage_grid, amount)
	if int(unit["hp"]) <= 0:
		_remove_unit(unit)
		if defeated_enemy_hero:
			call_deferred("_return_to_three_option_after_victory")


func _return_to_three_option_after_victory() -> void:
	if _battle_return_started:
		return

	_battle_return_started = true
	_phase = PHASE_ACTION
	_set_begin_button_disabled(true)
	_set_auto_arrange_button_disabled(true)

	await get_tree().create_timer(0.65).timeout

	get_tree().set_meta(RETURN_FROM_BATTLE_META, true)
	screen_requested.emit(SCREEN_IDS.ARTIST_FLOW, {})


func _show_damage_number(grid: Vector2i, amount: int) -> void:
	if amount <= 0:
		return

	var damage_label := DAMAGE_NUMBER_SCENE.instantiate() as Label
	if damage_label == null:
		return
	add_child(damage_label)
	damage_label.position = _cell_center(grid) + Vector2(-38.0, -48.0)
	damage_label.call("setup", amount)
	damage_label.call("play")


func _remove_unit(unit: Dictionary) -> void:
	if not _selected_unit.is_empty() and _selected_unit == unit:
		_selected_unit = {}
	if not _dragged_unit.is_empty() and _dragged_unit == unit:
		_dragged_unit = {}
		_drag_origin_grid = Vector2i(-1, -1)

	var index := _units.find(unit)
	if index >= 0:
		_units.remove_at(index)
	if unit.has("node") and is_instance_valid(unit["node"]):
		unit["node"].queue_free()


func _place_trap(grid: Vector2i, element: String, damage: int) -> void:
	var key := _grid_key(grid)
	if _traps.has(key):
		var existing_trap: Dictionary = _traps[key]
		existing_trap["damage"] = int(existing_trap.get("damage", 0)) + damage
		if existing_trap.has("damage_label") and is_instance_valid(existing_trap["damage_label"]):
			var existing_damage_label := existing_trap["damage_label"] as Label
			existing_damage_label.text = "%d" % int(existing_trap["damage"])
		_traps[key] = existing_trap
		return

	var trap_sprite := Sprite2D.new()
	add_child(trap_sprite)
	trap_sprite.name = "Trap_%s" % key.replace(":", "_")
	trap_sprite.z_index = 6
	trap_sprite.texture = _buff_texture_for_element(element)
	trap_sprite.position = _cell_center(grid)
	trap_sprite.scale = _buff_scale_for_cell(trap_sprite.texture)
	trap_sprite.modulate = Color(1.0, 1.0, 1.0, 0.82)

	var damage_label := Label.new()
	add_child(damage_label)
	damage_label.name = "TrapDamage_%s" % key.replace(":", "_")
	damage_label.z_index = 7
	damage_label.position = _cell_origin(grid) + Vector2(_cell_size.x - 42.0, 8.0)
	damage_label.size = Vector2(34.0, 28.0)
	damage_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	damage_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	damage_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	damage_label.text = "%d" % damage
	damage_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.24))
	damage_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.9))
	damage_label.add_theme_constant_override("shadow_offset_x", 2)
	damage_label.add_theme_constant_override("shadow_offset_y", 2)
	damage_label.add_theme_font_size_override("font_size", 22)

	_traps[key] = {
		"node": trap_sprite,
		"damage_label": damage_label,
		"grid": grid,
		"element": element,
		"damage": damage,
	}


func _remove_trap(key: String) -> void:
	if not _traps.has(key):
		return

	var trap: Dictionary = _traps[key]
	if trap.has("node") and is_instance_valid(trap["node"]):
		trap["node"].queue_free()
	if trap.has("damage_label") and is_instance_valid(trap["damage_label"]):
		trap["damage_label"].queue_free()
	_traps.erase(key)


func _trigger_trap_at_enemy_grid(enemy: Dictionary) -> void:
	if not _is_unit_active(enemy):
		return

	var key := _grid_key(Vector2i(enemy["grid"]))
	if not _traps.has(key):
		return

	var trap: Dictionary = _traps[key]
	var damage := int(trap["damage"])
	_remove_trap(key)
	_damage_unit(enemy, damage)


func _shoot_bullet_to_grid(attacker: Dictionary, target_grid: Vector2i) -> Sprite2D:
	return _shoot_bullet_to_position(attacker, _cell_center(target_grid))


func _shoot_bullet_to_unit(attacker: Dictionary, target: Dictionary, shot_index: int) -> Sprite2D:
	var target_position := _cell_center(Vector2i(target["grid"])) + _hero_barrage_impact_offset(attacker, shot_index)
	return _shoot_bullet_to_position(attacker, target_position)


func _shoot_bullet_to_position(attacker: Dictionary, target_position: Vector2) -> Sprite2D:
	var bullet := ELEMENT_BULLET_SCENE.instantiate() as Sprite2D
	if bullet == null:
		return null
	add_child(bullet)
	var start_position := _cell_center(Vector2i(attacker["grid"]))
	bullet.call("setup", _bullet_texture_for_element(String(attacker["element"])), start_position)
	bullet.call("play", target_position, BULLET_FLIGHT_DURATION, BULLET_ARC_MIN_HEIGHT, BULLET_ARC_DISTANCE_SCALE)
	return bullet


func _hero_barrage_impact_offset(attacker: Dictionary, shot_index: int) -> Vector2:
	var source_id := _unit_source_id(attacker)
	var angle := deg_to_rad(float((source_id + shot_index * 137) % 360))
	var radius: float = min(_cell_size.x, _cell_size.y) * (0.08 + 0.035 * float(shot_index % 3))
	return Vector2(cos(angle), sin(angle)) * radius


func _set_bullet_arc_progress(progress: float, bullet: Sprite2D, start_position: Vector2, target_position: Vector2, arc_height: float) -> void:
	if not is_instance_valid(bullet):
		return

	bullet.position = _bullet_arc_position(start_position, target_position, arc_height, progress)
	bullet.rotation = _bullet_arc_tangent(start_position, target_position, arc_height, progress).angle()


func _bullet_arc_position(start_position: Vector2, target_position: Vector2, arc_height: float, progress: float) -> Vector2:
	var base_position := start_position.lerp(target_position, progress)
	var height_offset := sin(progress * PI) * arc_height
	return base_position + Vector2.UP * height_offset


func _bullet_arc_tangent(start_position: Vector2, target_position: Vector2, arc_height: float, progress: float) -> Vector2:
	return target_position - start_position + Vector2.UP * cos(progress * PI) * PI * arc_height


func _bullet_arc_height(start_position: Vector2, target_position: Vector2) -> float:
	var distance := start_position.distance_to(target_position)
	return max(BULLET_ARC_MIN_HEIGHT, distance * BULLET_ARC_DISTANCE_SCALE)


func _find_unit_at(grid: Vector2i) -> Variant:
	for unit in _units:
		if Vector2i(unit["grid"]) == grid:
			return unit
	return null


func _find_enemy_at(grid: Vector2i) -> Dictionary:
	for unit in _units:
		if unit["team"] == TEAM_ENEMY and Vector2i(unit["grid"]) == grid:
			return unit
	return {}


func _find_enemy_hero() -> Dictionary:
	for unit in _units:
		if unit["team"] == TEAM_ENEMY and bool(unit.get("is_hero", false)):
			return unit
	return {}


func _has_active_enemy_pieces() -> bool:
	for unit in _units:
		if unit["team"] == TEAM_ENEMY and not bool(unit.get("is_hero", false)):
			return true
	return false


func _find_enemy_attack_target(enemy: Dictionary) -> Dictionary:
	var best_target: Dictionary = {}
	var best_distance := INF
	for unit in _units:
		if unit["team"] != TEAM_PLAYER:
			continue

		var distance := _grid_distance(Vector2i(enemy["grid"]), Vector2i(unit["grid"]))
		if distance <= int(_battle_defaults.get("enemy_attack_range", 1)) and distance < best_distance:
			best_target = unit
			best_distance = distance

	return best_target


func _best_enemy_move_grid(enemy: Dictionary) -> Vector2i:
	var origin := Vector2i(enemy["grid"])
	var current_distance := _nearest_player_distance(origin)
	if current_distance == INF:
		return origin

	var best_grid := origin
	var best_distance := current_distance
	var directions: Array[Vector2i] = [
		Vector2i.RIGHT,
		Vector2i.DOWN,
		Vector2i.LEFT,
		Vector2i.UP,
	]

	for direction in directions:
		var candidate := origin + direction
		if not _is_inside_board(candidate):
			continue
		if _find_unit_at(candidate) != null:
			continue

		var candidate_distance := _nearest_player_distance(candidate)
		if candidate_distance < best_distance:
			best_grid = candidate
			best_distance = candidate_distance

	return best_grid


func _nearest_player_distance(grid: Vector2i) -> float:
	var best_distance := INF
	for unit in _units:
		if unit["team"] != TEAM_PLAYER:
			continue
		best_distance = min(best_distance, float(_grid_distance(grid, Vector2i(unit["grid"]))))
	return best_distance


func _find_unit_by_node(node: Control) -> Dictionary:
	for unit in _units:
		if unit["node"] == node:
			return unit
	return {}


func _is_unit_active(unit: Dictionary) -> bool:
	return not unit.is_empty() and _units.find(unit) >= 0 and unit.has("node") and is_instance_valid(unit["node"])


func _is_unit_movable(unit: Dictionary) -> bool:
	return bool(unit.get("movable", true))


func _refresh_damage_previews(override_unit: Dictionary, override_grid: Vector2i, use_override: bool) -> void:
	_clear_damage_previews()
	if _phase != PHASE_DEPLOY:
		return

	var preview := _calculate_turn_damage_preview(override_unit, override_grid, use_override)
	var dealt_damage: Dictionary = preview["dealt"]
	var incoming_damage: Dictionary = preview["incoming"]

	for unit in _units:
		var source_id := _unit_source_id(unit)
		var shown_damage := 0
		if unit["team"] == TEAM_ENEMY and dealt_damage.has(source_id):
			shown_damage = int(dealt_damage[source_id])
			_show_health_preview(unit, shown_damage)
		elif unit["team"] == TEAM_PLAYER and incoming_damage.has(source_id):
			shown_damage = int(incoming_damage[source_id])
			_show_incoming_damage_preview(unit, shown_damage)

		if _death_preview_marks_enabled and shown_damage >= int(unit["hp"]):
			_show_death_mark_preview(unit)


func _show_health_preview(unit: Dictionary, damage: int) -> void:
	if damage <= 0:
		return

	var preview_hp: int = maxi(0, int(unit["hp"]) - damage)
	var hp_label := unit["hp_label"] as Label
	_set_stat_label_value(hp_label, preview_hp)
	hp_label.add_theme_color_override("font_color", STAT_NUMBER_PREVIEW_COLOR)


func _show_incoming_damage_preview(unit: Dictionary, damage: int) -> void:
	_show_health_preview(unit, damage)
	_show_damage_preview_label(unit, damage, STAT_NUMBER_PREVIEW_COLOR, HORIZONTAL_ALIGNMENT_LEFT)


func _show_damage_preview_label(unit: Dictionary, damage: int, color: Color, alignment: HorizontalAlignment) -> void:
	if damage <= 0:
		return

	var label := unit["damage_preview_label"] as Label
	label.horizontal_alignment = alignment
	label.add_theme_color_override("font_color", color)
	label.text = "-%d" % damage
	label.visible = true


func _show_death_mark_preview(unit: Dictionary) -> void:
	if not unit.has("death_mark") or not is_instance_valid(unit["death_mark"]):
		return

	var mark := unit["death_mark"] as Sprite2D
	mark.texture = _death_mark_texture_for_unit(String(unit["team"]))
	mark.scale = _death_mark_preview_scale(mark.texture)
	mark.visible = true


func _calculate_turn_damage_preview(override_unit: Dictionary, override_grid: Vector2i, use_override: bool) -> Dictionary:
	var override_positions := {}
	if use_override and not override_unit.is_empty() and _is_inside_board(override_grid):
		override_positions[_unit_source_id(override_unit)] = override_grid
	return _calculate_turn_damage_preview_for_positions(override_positions)


func _calculate_turn_damage_preview_for_positions(player_positions: Dictionary) -> Dictionary:
	var sim_units := _make_sim_units(player_positions)
	var sim_traps := _make_sim_traps()
	var dealt_damage := {}
	var incoming_damage := {}

	_simulate_player_action(sim_units, sim_traps, dealt_damage)
	if not _sim_find_enemy_hero(sim_units).is_empty():
		if _sim_should_trigger_enemy_hero_barrage(sim_units):
			_simulate_enemy_hero_barrage(sim_units, dealt_damage)
		if not _sim_find_enemy_hero(sim_units).is_empty():
			_simulate_enemy_action(sim_units, sim_traps, incoming_damage, dealt_damage)

	return {
		"dealt": dealt_damage,
		"incoming": incoming_damage,
	}


func _make_sim_units(player_positions: Dictionary) -> Array[Dictionary]:
	var sim_units: Array[Dictionary] = []
	for unit in _units:
		var grid := Vector2i(unit["grid"])
		var source_id := _unit_source_id(unit)
		if unit["team"] == TEAM_PLAYER and player_positions.has(source_id):
			var candidate_grid := Vector2i(player_positions[source_id])
			if _is_inside_board(candidate_grid):
				grid = candidate_grid

		sim_units.append({
			"source_id": source_id,
			"team": String(unit["team"]),
			"element": String(unit["element"]),
			"grid": grid,
			"hp": int(unit["hp"]),
			"attack_damage": int(unit["attack_damage"]),
			"move_distance": int(unit.get("move_distance", int(_battle_defaults.get("enemy_move_distance", 1)))),
			"movable": bool(unit.get("movable", true)),
			"is_hero": bool(unit.get("is_hero", false)),
		})
	return sim_units


func _make_sim_traps() -> Dictionary:
	var sim_traps := {}
	for key in _traps.keys():
		var trap: Dictionary = _traps[key]
		sim_traps[key] = {
			"grid": Vector2i(trap["grid"]),
			"element": String(trap["element"]),
			"damage": int(trap["damage"]),
		}
	return sim_traps


func _simulate_player_action(sim_units: Array[Dictionary], sim_traps: Dictionary, dealt_damage: Dictionary) -> void:
	for attacker in sim_units.duplicate():
		if not _sim_is_unit_active(sim_units, attacker) or attacker["team"] != TEAM_PLAYER:
			continue
		if int(attacker["attack_damage"]) <= 0:
			continue

		for direction in _player_attack_directions:
			var targets: Array[Dictionary] = []
			var trap_grids: Array[Vector2i] = []
			for grid in _player_attack_cells_for_direction(Vector2i(attacker["grid"]), direction):
				var enemy := _sim_find_enemy_at(sim_units, grid)
				if not enemy.is_empty():
					targets.append(enemy)
				elif _sim_find_unit_at(sim_units, grid) == null:
					trap_grids.append(grid)

			for target in targets:
				_sim_damage_unit(sim_units, target, int(attacker["attack_damage"]), dealt_damage)
			for grid in trap_grids:
				_sim_place_trap(sim_traps, grid, String(attacker["element"]), int(attacker["attack_damage"]))


func _sim_should_trigger_enemy_hero_barrage(sim_units: Array[Dictionary]) -> bool:
	return not _sim_find_enemy_hero(sim_units).is_empty() and not _sim_has_active_enemy_pieces(sim_units)


func _simulate_enemy_hero_barrage(sim_units: Array[Dictionary], dealt_damage: Dictionary) -> void:
	var hero := _sim_find_enemy_hero(sim_units)
	var volley_count := 0
	while _sim_is_unit_active(sim_units, hero) and volley_count < int(_battle_data.get("hero_barrage_max_volleys", 64)):
		var attackers := _sim_active_player_attackers(sim_units)
		if attackers.is_empty():
			return

		for shot_index in int(_battle_data.get("hero_barrage_bullets_per_attacker", 4)):
			for attacker in attackers:
				if _sim_is_unit_active(sim_units, hero):
					_sim_damage_unit(sim_units, hero, int(attacker["attack_damage"]), dealt_damage)
		volley_count += 1


func _sim_active_player_attackers(sim_units: Array[Dictionary]) -> Array[Dictionary]:
	var attackers: Array[Dictionary] = []
	for unit in sim_units:
		if unit["team"] == TEAM_PLAYER and int(unit["attack_damage"]) > 0:
			attackers.append(unit)
	return attackers


func _simulate_enemy_action(sim_units: Array[Dictionary], sim_traps: Dictionary, incoming_damage: Dictionary, dealt_damage: Dictionary) -> void:
	for enemy in sim_units.duplicate():
		if not _sim_is_unit_active(sim_units, enemy) or enemy["team"] != TEAM_ENEMY:
			continue

		var target := _sim_find_enemy_attack_target(sim_units, enemy)
		if target.is_empty():
			_sim_move_enemy_toward_player(sim_units, sim_traps, enemy, dealt_damage)
			if not _sim_is_unit_active(sim_units, enemy):
				if _sim_should_trigger_enemy_hero_barrage(sim_units):
					_simulate_enemy_hero_barrage(sim_units, dealt_damage)
				continue
			target = _sim_find_enemy_attack_target(sim_units, enemy)

		if not target.is_empty():
			_sim_damage_unit(sim_units, target, int(enemy["attack_damage"]), incoming_damage)


func _sim_move_enemy_toward_player(sim_units: Array[Dictionary], sim_traps: Dictionary, enemy: Dictionary, dealt_damage: Dictionary) -> void:
	if not bool(enemy.get("movable", true)):
		return

	var move_distance := int(enemy.get("move_distance", int(_battle_defaults.get("enemy_move_distance", 1))))
	for step in move_distance:
		if not _sim_find_enemy_attack_target(sim_units, enemy).is_empty():
			return

		var target_grid := _sim_best_enemy_move_grid(sim_units, enemy)
		if target_grid == Vector2i(enemy["grid"]):
			return

		enemy["grid"] = target_grid
		_sim_trigger_trap_at_enemy_grid(sim_units, sim_traps, enemy, dealt_damage)
		if not _sim_is_unit_active(sim_units, enemy):
			return


func _sim_damage_unit(sim_units: Array[Dictionary], unit: Dictionary, amount: int, damage_totals: Dictionary) -> void:
	if amount <= 0 or not _sim_is_unit_active(sim_units, unit):
		return

	var actual_damage: int = min(int(unit["hp"]), amount)
	if actual_damage > 0:
		var source_id := int(unit["source_id"])
		damage_totals[source_id] = int(damage_totals.get(source_id, 0)) + actual_damage
	unit["hp"] = max(0, int(unit["hp"]) - amount)
	if int(unit["hp"]) <= 0:
		_sim_remove_unit(sim_units, unit)


func _sim_place_trap(sim_traps: Dictionary, grid: Vector2i, element: String, damage: int) -> void:
	var key := _grid_key(grid)
	if sim_traps.has(key):
		var existing_trap: Dictionary = sim_traps[key]
		existing_trap["damage"] = int(existing_trap.get("damage", 0)) + damage
		sim_traps[key] = existing_trap
		return

	sim_traps[key] = {
		"grid": grid,
		"element": element,
		"damage": damage,
	}


func _sim_trigger_trap_at_enemy_grid(sim_units: Array[Dictionary], sim_traps: Dictionary, enemy: Dictionary, dealt_damage: Dictionary) -> void:
	var key := _grid_key(Vector2i(enemy["grid"]))
	if not sim_traps.has(key):
		return

	var trap: Dictionary = sim_traps[key]
	sim_traps.erase(key)
	_sim_damage_unit(sim_units, enemy, int(trap["damage"]), dealt_damage)


func _sim_find_enemy_attack_target(sim_units: Array[Dictionary], enemy: Dictionary) -> Dictionary:
	var best_target: Dictionary = {}
	var best_distance := INF
	for unit in sim_units:
		if unit["team"] != TEAM_PLAYER:
			continue

		var distance := _grid_distance(Vector2i(enemy["grid"]), Vector2i(unit["grid"]))
		if distance <= int(_battle_defaults.get("enemy_attack_range", 1)) and distance < best_distance:
			best_target = unit
			best_distance = distance

	return best_target


func _sim_best_enemy_move_grid(sim_units: Array[Dictionary], enemy: Dictionary) -> Vector2i:
	var origin := Vector2i(enemy["grid"])
	var current_distance := _sim_nearest_player_distance(sim_units, origin)
	if current_distance == INF:
		return origin

	var best_grid := origin
	var best_distance := current_distance
	var directions: Array[Vector2i] = [
		Vector2i.RIGHT,
		Vector2i.DOWN,
		Vector2i.LEFT,
		Vector2i.UP,
	]

	for direction in directions:
		var candidate := origin + direction
		if not _is_inside_board(candidate):
			continue
		if _sim_find_unit_at(sim_units, candidate) != null:
			continue

		var candidate_distance := _sim_nearest_player_distance(sim_units, candidate)
		if candidate_distance < best_distance:
			best_grid = candidate
			best_distance = candidate_distance

	return best_grid


func _sim_nearest_player_distance(sim_units: Array[Dictionary], grid: Vector2i) -> float:
	var best_distance := INF
	for unit in sim_units:
		if unit["team"] != TEAM_PLAYER:
			continue
		best_distance = min(best_distance, float(_grid_distance(grid, Vector2i(unit["grid"]))))
	return best_distance


func _sim_find_unit_at(sim_units: Array[Dictionary], grid: Vector2i) -> Variant:
	for unit in sim_units:
		if Vector2i(unit["grid"]) == grid:
			return unit
	return null


func _sim_find_enemy_at(sim_units: Array[Dictionary], grid: Vector2i) -> Dictionary:
	for unit in sim_units:
		if unit["team"] == TEAM_ENEMY and Vector2i(unit["grid"]) == grid:
			return unit
	return {}


func _sim_find_enemy_hero(sim_units: Array[Dictionary]) -> Dictionary:
	for unit in sim_units:
		if unit["team"] == TEAM_ENEMY and bool(unit.get("is_hero", false)):
			return unit
	return {}


func _sim_has_active_enemy_pieces(sim_units: Array[Dictionary]) -> bool:
	for unit in sim_units:
		if unit["team"] == TEAM_ENEMY and not bool(unit.get("is_hero", false)):
			return true
	return false


func _sim_is_unit_active(sim_units: Array[Dictionary], unit: Dictionary) -> bool:
	return not unit.is_empty() and sim_units.find(unit) >= 0


func _sim_remove_unit(sim_units: Array[Dictionary], unit: Dictionary) -> void:
	var index := sim_units.find(unit)
	if index >= 0:
		sim_units.remove_at(index)


func _unit_source_id(unit: Dictionary) -> int:
	var node := unit["node"] as Control
	return int(node.get_instance_id())


func _clear_damage_previews() -> void:
	for unit in _units:
		if unit.has("hp_label") and is_instance_valid(unit["hp_label"]):
			var hp_label := unit["hp_label"] as Label
			_set_stat_label_value(hp_label, int(unit["hp"]))
			hp_label.add_theme_color_override("font_color", STAT_NUMBER_COLOR)
		if unit.has("damage_preview_label") and is_instance_valid(unit["damage_preview_label"]):
			var label := unit["damage_preview_label"] as Label
			label.text = ""
			label.visible = false
		if unit.has("death_mark") and is_instance_valid(unit["death_mark"]):
			var mark := unit["death_mark"] as Sprite2D
			mark.visible = false


func _position_to_board_index(local_position: Vector2) -> Vector2i:
	for row in BOARD_ROWS:
		for column in BOARD_COLUMNS:
			var grid := Vector2i(column, row)
			var rect := Rect2(_cell_origin(grid), _cell_size)
			if rect.has_point(local_position):
				return grid
	return Vector2i(-1, -1)


func _coord_to_board_index(coord: String) -> Vector2i:
	if coord.length() < 2:
		return Vector2i(-1, -1)

	var file := coord.substr(coord.length() - 1, 1).to_lower()
	var column := FILE_LABELS.find(file)
	var row := int(coord.substr(0, coord.length() - 1)) - 1
	if column < 0 or row < 0:
		return Vector2i(-1, -1)
	return Vector2i(column, row)


func _cell_origin(grid: Vector2i) -> Vector2:
	return Vector2(
		float(grid.x) * (_cell_size.x + CELL_GAP.x),
		float(grid.y) * (_cell_size.y + CELL_GAP.y)
	)


func _cell_center(grid: Vector2i) -> Vector2:
	return _cell_origin(grid) + _cell_size * 0.5


func _file_label(column: int) -> String:
	return FILE_LABELS.substr(column, 1)


func _grid_key(grid: Vector2i) -> String:
	return "%d:%d" % [grid.x, grid.y]


func _is_inside_board(grid: Vector2i) -> bool:
	return grid.x >= 0 and grid.x < BOARD_COLUMNS and grid.y >= 0 and grid.y < BOARD_ROWS


func _grid_distance(from_grid: Vector2i, to_grid: Vector2i) -> int:
	return abs(from_grid.x - to_grid.x) + abs(from_grid.y - to_grid.y)


func _texture_for_element(element: String) -> Texture2D:
	match element:
		"fire":
			return FIRE_SPRITE
		"water":
			return WATER_SPRITE
		_:
			return FIRE_SPRITE


func _bullet_texture_for_element(element: String) -> Texture2D:
	match element:
		"fire":
			return FIRE_BULLET
		"water":
			return WATER_BULLET
		"earth":
			return EARTH_BULLET
		"wind":
			return WIND_BULLET
		_:
			return FIRE_BULLET


func _buff_texture_for_element(element: String) -> Texture2D:
	match element:
		"fire":
			return FIRE_BUFF
		"water":
			return WATER_BUFF
		"earth":
			return EARTH_BUFF
		"wind":
			return WIND_BUFF
		_:
			return FIRE_BUFF


func _death_mark_texture_for_unit(team: String) -> Texture2D:
	if team == TEAM_ENEMY:
		return ENEMY_DEATH_MARK
	return PLAYER_DEATH_MARK


func _sprite_layout_for_cell(texture: Texture2D) -> Dictionary:
	var texture_size := texture.get_size()
	var visible_rect := Rect2(Vector2.ZERO, texture_size)
	var image := texture.get_image()
	if image != null:
		var used_rect := image.get_used_rect()
		if used_rect.size.x > 0 and used_rect.size.y > 0:
			visible_rect = Rect2(used_rect)

	# Size every creature by its visible pixels rather than by the transparent
	# canvas around it. Feet share one baseline near the lower stat badge while
	# heads reach slightly above the cell, matching the marked reference bounds.
	var target_top := _cell_size.y * UNIT_VISIBLE_TOP_RATIO
	var target_bottom := _cell_size.y * UNIT_VISIBLE_BOTTOM_RATIO
	var scale_value := (target_bottom - target_top) / visible_rect.size.y
	var visible_center_in_texture := visible_rect.position + visible_rect.size * 0.5 - texture_size * 0.5
	var position := Vector2(
		_cell_size.x * 0.5 - visible_center_in_texture.x * scale_value,
		(target_top + target_bottom) * 0.5 - visible_center_in_texture.y * scale_value
	)
	return {"position": position, "scale": scale_value, "visible_rect": visible_rect}


func _sprite_scale_for_cell(texture: Texture2D) -> Vector2:
	return Vector2.ONE * float(_sprite_layout_for_cell(texture)["scale"])


func _death_mark_preview_scale(texture: Texture2D) -> Vector2:
	var texture_size := texture.get_size()
	var target_size: float = min(_cell_size.x, _cell_size.y) * 0.38
	var scale_value: float = min(target_size / texture_size.x, target_size / texture_size.y)
	return Vector2.ONE * scale_value


func _buff_scale_for_cell(texture: Texture2D) -> Vector2:
	var texture_size := texture.get_size()
	var scale_value: float = min(_cell_size.x / texture_size.x, _cell_size.y / texture_size.y) * 0.74
	return Vector2.ONE * scale_value


func _monster_bite_scale() -> Vector2:
	var texture_size := MONSTER_BITE_FRAME_01.get_size()
	var scale_value: float = min(_cell_size.x / texture_size.x, _cell_size.y / texture_size.y) * MONSTER_BITE_SCALE
	return Vector2.ONE * scale_value


func _update_unit_visual(unit: Dictionary) -> void:
	var node := unit["node"] as Control
	var sprite := unit["sprite"] as Sprite2D
	var hp_label := unit["hp_label"] as Label
	var attack_label := unit["attack_label"] as Label
	node.modulate = Color.WHITE
	sprite.modulate = Color.WHITE
	if node.has_method("update_hp"):
		node.call("update_hp", int(unit["hp"]))
	else:
		_set_stat_label_value(hp_label, int(unit["hp"]))
	if node.has_method("update_attack"):
		node.call("update_attack", int(unit["attack_damage"]))
	else:
		_set_stat_label_value(attack_label, int(unit["attack_damage"]))
	hp_label.add_theme_color_override("font_color", STAT_NUMBER_COLOR)
	attack_label.add_theme_color_override("font_color", STAT_NUMBER_COLOR)


func _set_stat_label_value(label: Label, value: int) -> void:
	label.text = "%d" % value
	var digit_count := label.text.length()
	var font_size := 30
	if digit_count == 3:
		font_size = 27
	elif digit_count >= 4:
		font_size = 23
	label.add_theme_font_size_override("font_size", font_size)


func _apply_unit_frame_style(unit: Dictionary, selected: bool) -> void:
	# Selection is communicated by cell highlights and drag modulation. Units no
	# longer carry a red or blue team frame; health icon color identifies sides.
	var node := unit.get("node") as Control
	if node != null and node.has_method("set_selected"):
		node.call("set_selected", selected)


func _set_unit_dragging_visual(unit: Dictionary, dragging: bool) -> void:
	var node := unit["node"] as Control
	if node.has_method("set_dragging"):
		node.call("set_dragging", dragging)
	else:
		node.z_index = 40 if dragging else 10
		node.modulate = Color(1.0, 1.0, 1.0, 0.82) if dragging else Color.WHITE


func _set_begin_button_disabled(disabled: bool) -> void:
	if is_instance_valid(_begin_turn_button):
		_begin_turn_button.disabled = disabled


func _set_auto_arrange_button_disabled(disabled: bool) -> void:
	if is_instance_valid(_auto_arrange_button):
		_auto_arrange_button.disabled = disabled


func _make_cell_style(highlight_type: String) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	if highlight_type == HIGHLIGHT_DEPLOY:
		# Deployment cells should read as a board outline, not as a blue overlay.
		style.bg_color = CELL_OUTLINE_BACKGROUND
		style.border_color = CELL_OUTLINE_COLOR
	elif highlight_type == HIGHLIGHT_ATTACK_PREVIEW:
		style.bg_color = Color(0.92, 0.1, 0.08, 0.42)
		style.border_color = Color(1.0, 0.2, 0.18, 0.78)
	elif highlight_type == HIGHLIGHT_ATTACK_LOCKED:
		style.bg_color = Color(0.92, 0.1, 0.08, 0.42)
		style.border_color = Color(1.0, 0.2, 0.18, 0.78)
	else:
		style.bg_color = CELL_OUTLINE_BACKGROUND
		style.border_color = CELL_OUTLINE_COLOR
	style.border_width_left = CELL_BORDER_WIDTH
	style.border_width_top = CELL_BORDER_WIDTH
	style.border_width_right = CELL_BORDER_WIDTH
	style.border_width_bottom = CELL_BORDER_WIDTH
	style.corner_radius_top_left = CELL_CORNER_RADIUS
	style.corner_radius_top_right = CELL_CORNER_RADIUS
	style.corner_radius_bottom_left = CELL_CORNER_RADIUS
	style.corner_radius_bottom_right = CELL_CORNER_RADIUS
	style.shadow_color = CELL_OUTLINE_SHADOW
	style.shadow_size = CELL_SHADOW_SIZE
	style.shadow_offset = CELL_SHADOW_OFFSET
	return style
