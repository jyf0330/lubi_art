extends SceneTree

const BATTLE_SCENE := "res://Features/Battle/Views/BattleMainView.tscn"
const EXPECTED_CELL_COUNT := 56
const EXPECTED_UNIT_COUNT := 7
const BATTLE_BACKGROUND_PATHS := [
	"res://Features/Battle/Art/UI/battle_bg/bg1(1).png",
	"res://Features/Battle/Art/UI/battle_bg/bg2.png",
	"res://Features/Battle/Art/UI/battle_bg/bg3.png",
]
const PLAYER_HEALTH_ICON_PATH := "res://Features/Battle/Art/UI/health-icon-green.png"
const ENEMY_HEALTH_ICON_PATH := "res://Features/Battle/Art/UI/health-icon.png"
const EXPECTED_STAT_ORB_RADIUS := 20.0
const EXPECTED_STAT_ORB_CORNER_OVERLAP := 6.0
const EXPECTED_UNIT_VISIBLE_TOP_RATIO := -0.15
const EXPECTED_UNIT_VISIBLE_BOTTOM_RATIO := 0.86
const EXPECTED_UNIT_SHADOW_WIDTH_RATIO := 0.72
const EXPECTED_UNIT_SHADOW_CENTER_Y_OFFSET := -5.0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	if not Engine.is_editor_hint():
		_fail("This smoke test must run with --editor")
		return

	var packed_scene := load(BATTLE_SCENE) as PackedScene
	if packed_scene == null:
		_fail("Unable to load the battle scene")
		return

	var scene := packed_scene.instantiate()
	root.add_child(scene)
	await process_frame
	await process_frame

	var board := scene.get_node_or_null("BoardGrid")
	if board == null:
		_fail("The battle scene has no BoardGrid")
		return
	board.call("_clear_damage_previews")

	var cell_count := 0
	var unit_count := 0
	var status_badge_count := 0
	var cell_size: Vector2 = board.get("_cell_size")
	for child in board.get_children():
		if child.name.begins_with("Cell_"):
			cell_count += 1
		elif child.name.begins_with("Unit_"):
			unit_count += 1
			var shadow := child.get_node_or_null("UnitShadow") as Control
			if shadow == null or shadow.get_node_or_null("PixelShadow") == null:
				_fail("A unit is missing its foot shadow: %s" % child.name)
				return
			var shadow_width := shadow.size.x * shadow.scale.x
			var shadow_center := shadow.position + shadow.size * shadow.scale * 0.5
			if not is_equal_approx(shadow_width, cell_size.x * EXPECTED_UNIT_SHADOW_WIDTH_RATIO):
				_fail("A unit foot shadow has the wrong width: %s" % child.name)
				return
			if not is_equal_approx(shadow_center.x, cell_size.x * 0.5):
				_fail("A unit foot shadow is not horizontally centered: %s" % child.name)
				return
			var expected_shadow_center_y := cell_size.y * EXPECTED_UNIT_VISIBLE_BOTTOM_RATIO + EXPECTED_UNIT_SHADOW_CENTER_Y_OFFSET
			if not is_equal_approx(shadow_center.y, expected_shadow_center_y):
				_fail("A unit foot shadow is not tucked against its feet: %s" % child.name)
				return
			if shadow.z_index >= 0:
				_fail("A unit foot shadow is not behind its sprite: %s" % child.name)
				return
			var sprite := child.get_node_or_null("Sprite") as Sprite2D
			if sprite == null or sprite.texture == null:
				_fail("A unit is missing its creature sprite: %s" % child.name)
				return
			var image := sprite.texture.get_image()
			var visible_rect := image.get_used_rect() if image != null else Rect2i(Vector2i.ZERO, Vector2i(sprite.texture.get_size()))
			var texture_size := sprite.texture.get_size()
			var visible_top := sprite.position.y + (float(visible_rect.position.y) - texture_size.y * 0.5) * sprite.scale.y
			var visible_bottom := sprite.position.y + (float(visible_rect.end.y) - texture_size.y * 0.5) * sprite.scale.y
			if not is_equal_approx(visible_top, cell_size.y * EXPECTED_UNIT_VISIBLE_TOP_RATIO):
				_fail("Unit head does not reach the shared upper guide: %s at %s" % [child.name, visible_top])
				return
			if not is_equal_approx(visible_bottom, cell_size.y * EXPECTED_UNIT_VISIBLE_BOTTOM_RATIO):
				_fail("Unit feet do not reach the shared lower guide: %s at %s" % [child.name, visible_bottom])
				return
			if child.get_node_or_null("TeamFrame") != null:
				_fail("A unit still has a red/blue team frame: %s" % child.name)
				return
			var health_icon := child.get_node_or_null("HealthIcon") as TextureRect
			var attack_icon := child.get_node_or_null("AttackIcon") as TextureRect
			var hp_label := child.get_node_or_null("HpLabel") as Label
			var attack_label := child.get_node_or_null("AttackLabel") as Label
			if health_icon == null or attack_icon == null or hp_label == null or attack_label == null:
				_fail("A unit is missing its health/attack badge: %s" % child.name)
				return
			if health_icon.position.y >= attack_icon.position.y:
				_fail("Unit stat badges are not placed at the upper/lower left: %s" % child.name)
				return
			var health_orb_radius := health_icon.size.y * 0.39
			if not is_equal_approx(health_orb_radius, EXPECTED_STAT_ORB_RADIUS):
				_fail("Health orb radius is not 20 pixels: %s" % child.name)
				return
			var health_orb_center := health_icon.position + health_icon.size * Vector2(0.5, 0.62)
			if not is_equal_approx(health_orb_center.x - health_orb_radius, -EXPECTED_STAT_ORB_CORNER_OVERLAP) or not is_equal_approx(health_orb_center.y - health_orb_radius, -EXPECTED_STAT_ORB_CORNER_OVERLAP):
				_fail("Health orb is not aligned to the upper-left cell corner: %s" % child.name)
				return
			var attack_orb_radius := attack_icon.size.y * 0.39
			var attack_orb_center := attack_icon.position + attack_icon.size * Vector2(0.57, 0.59)
			if not is_equal_approx(attack_orb_center.x - attack_orb_radius, -EXPECTED_STAT_ORB_CORNER_OVERLAP) or not is_equal_approx(attack_orb_center.y + attack_orb_radius, cell_size.y + EXPECTED_STAT_ORB_CORNER_OVERLAP):
				_fail("Attack orb is not aligned to the lower-left cell corner: %s" % child.name)
				return
			if health_icon.position.y >= 0.0 or attack_icon.position.x >= 0.0 or attack_icon.position.y + attack_icon.size.y <= cell_size.y:
				_fail("Stat badge decorations are not allowed to extend past the cell: %s" % child.name)
				return
			if hp_label.get_theme_font_size("font_size") < 27 or attack_label.get_theme_font_size("font_size") < 27:
				_fail("Unit stat numbers are still too small: %s" % child.name)
				return
			if hp_label.get_theme_color("font_color") != Color.WHITE or attack_label.get_theme_color("font_color") != Color.WHITE:
				_fail("Normal unit stat numbers are not white: %s" % child.name)
				return
			if hp_label.get_theme_color("font_shadow_color").a < 0.9 or attack_label.get_theme_color("font_shadow_color").a < 0.9:
				_fail("Unit stat numbers are missing their dark shadow: %s" % child.name)
				return
			var health_atlas := health_icon.texture as AtlasTexture
			var expected_health_path := PLAYER_HEALTH_ICON_PATH if child.name.begins_with("Unit_player_") else ENEMY_HEALTH_ICON_PATH
			if health_atlas == null or health_atlas.atlas.resource_path != expected_health_path:
				_fail("Unit has the wrong team health icon: %s" % child.name)
				return
			status_badge_count += 1

	if cell_count != EXPECTED_CELL_COUNT:
		_fail("Editor preview did not create all board cells: %d" % cell_count)
		return
	if unit_count != EXPECTED_UNIT_COUNT:
		_fail("Editor preview did not create all starting units: %d" % unit_count)
		return
	if status_badge_count != EXPECTED_UNIT_COUNT:
		_fail("Editor preview did not validate all unit status badges: %d" % status_badge_count)
		return

	var enemy_preview_unit: Dictionary = {}
	for unit in board.get("_units"):
		if unit["team"] == "enemy" and int(unit["hp"]) >= 2:
			enemy_preview_unit = unit
			break
	if enemy_preview_unit.is_empty():
		_fail("Editor preview has no enemy available for the HP preview check")
		return
	var preview_unit_view := enemy_preview_unit["node"] as Control
	var preview_hp_label := preview_unit_view.get_node("HpLabel") as Label
	var original_hp := int(enemy_preview_unit["hp"])
	board.call("_show_health_preview", enemy_preview_unit, 2)
	if preview_hp_label.text != str(original_hp - 2):
		_fail("Enemy preview does not show post-damage HP: %s" % preview_hp_label.text)
		return
	if preview_hp_label.get_theme_color("font_color").r < 0.9:
		_fail("Enemy post-damage HP preview is not red")
		return
	board.call("_clear_damage_previews")
	if preview_hp_label.text != str(original_hp) or preview_hp_label.get_theme_color("font_color") != Color.WHITE:
		_fail("Clearing the damage preview did not restore normal enemy HP")
		return

	var player_preview_unit: Dictionary = {}
	for unit in board.get("_units"):
		if unit["team"] == "player" and not bool(unit.get("is_hero", false)) and int(unit["hp"]) >= 2:
			player_preview_unit = unit
			break
	if player_preview_unit.is_empty():
		_fail("Editor preview has no player unit available for the incoming-damage preview check")
		return
	var player_preview_view := player_preview_unit["node"] as Control
	var player_hp_label := player_preview_view.get_node("HpLabel") as Label
	var player_damage_label := player_preview_view.get_node("DamagePreviewLabel") as Label
	var original_player_hp := int(player_preview_unit["hp"])
	board.call("_show_incoming_damage_preview", player_preview_unit, 2)
	if player_hp_label.text != str(original_player_hp - 2) or player_hp_label.get_theme_color("font_color").g > 0.5:
		_fail("Player incoming-damage HP preview is not showing the reduced value in red")
		return
	if player_damage_label.text != "-2" or not player_damage_label.visible or player_damage_label.get_theme_color("font_color").g > 0.5:
		_fail("Player incoming-damage label is not red")
		return
	board.call("_clear_damage_previews")
	if player_hp_label.text != str(original_player_hp) or player_hp_label.get_theme_color("font_color") != Color.WHITE:
		_fail("Clearing the damage preview did not restore normal player HP")
		return

	var enemy_hero: Dictionary = {}
	var hero_attacker: Dictionary = {}
	for unit in board.get("_units"):
		if unit["team"] == "enemy" and bool(unit.get("is_hero", false)):
			enemy_hero = unit
		elif unit["team"] == "player" and not bool(unit.get("is_hero", false)) and int(unit["attack_damage"]) > 0:
			hero_attacker = unit
	if enemy_hero.is_empty() or hero_attacker.is_empty():
		_fail("Editor preview cannot validate a creature attack against the enemy hero")
		return
	var enemy_hero_grid := Vector2i(enemy_hero["grid"])
	var hero_attack_origin := enemy_hero_grid - Vector2i.RIGHT * 2
	board.call("_move_unit_to", hero_attacker, hero_attack_origin)
	var original_enemy_hero_hp := int(enemy_hero["hp"])
	await board.call("_resolve_player_attack_direction", hero_attacker, Vector2i.RIGHT)
	var expected_enemy_hero_hp := original_enemy_hero_hp - int(hero_attacker["attack_damage"])
	if int(enemy_hero["hp"]) != expected_enemy_hero_hp:
		_fail("A creature attack did not reduce the enemy hero HP: %d" % int(enemy_hero["hp"]))
		return
	var enemy_hero_view := enemy_hero["node"] as Control
	var enemy_hero_hp_label := enemy_hero_view.get_node("HpLabel") as Label
	if enemy_hero_hp_label.text != str(expected_enemy_hero_hp):
		_fail("The enemy hero HP label did not update after taking creature damage")
		return

	var deploy_style := board.call("_make_cell_style", "deploy") as StyleBoxFlat
	if deploy_style == null:
		_fail("Battle board did not create a deployment cell style")
		return
	if deploy_style.bg_color.a > 0.05:
		_fail("Deployment cells are not sufficiently transparent: %s" % deploy_style.bg_color)
		return
	var deploy_color_max := maxf(deploy_style.border_color.r, deploy_style.border_color.g)
	deploy_color_max = maxf(deploy_color_max, deploy_style.border_color.b)
	var deploy_color_min := minf(deploy_style.border_color.r, deploy_style.border_color.g)
	deploy_color_min = minf(deploy_color_min, deploy_style.border_color.b)
	var deploy_color_range: float = deploy_color_max - deploy_color_min
	if deploy_color_range > 0.10:
		_fail("Deployment cell outline still has a colored highlight: %s" % deploy_style.border_color)
		return
	var clock_indicator := scene.get_node_or_null("ClockIndicator") as Node2D
	if clock_indicator == null:
		_fail("Editor preview did not create the clock indicator")
		return
	if not clock_indicator.position.is_equal_approx(Vector2(22.0, 519.0)):
		_fail("Clock indicator is not positioned in the marked base area: %s" % clock_indicator.position)
		return
	var background_frame := scene.get_node_or_null("BackgroundFrame") as TextureRect
	if background_frame == null or background_frame.texture == null:
		_fail("Battle scene is missing the decorative background frame")
		return
	if background_frame.texture.resource_path != "res://Features/Battle/Art/UI/battle_interface_frame_2.png":
		_fail("Battle scene is not using the combined frame and clock base: %s" % background_frame.texture.resource_path)
		return

	var board_background := scene.get_node_or_null("BoardBG") as TextureRect
	if board_background == null or board_background.texture == null:
		_fail("Battle scene did not load a background")
		return
	if board_background.texture.resource_path not in BATTLE_BACKGROUND_PATHS:
		_fail("Battle scene loaded an unexpected background: %s" % board_background.texture.resource_path)
		return

	print("Battle editor preview smoke test passed.")
	scene.queue_free()
	await process_frame
	quit()


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
