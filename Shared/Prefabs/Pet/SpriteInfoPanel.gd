@tool
extends Control
class_name SpriteInfoPanel

const ART_DIR := "res://Shared/Prefabs/Pet/SpriteInfo/Art"

@onready var fallback_panel: PanelContainer = $FallbackPanel
@onready var panel_texture: TextureRect = $PanelTexture
@onready var border_texture: TextureRect = $QualityBorderTexture
@onready var header_view: SpriteInfoHeaderView = $PanelBackground/ContentMargin/Layout/SpriteInfoHeaderView
@onready var attack_pattern_view: SpriteInfoAttackPatternView = $PanelBackground/ContentMargin/Layout/SpriteInfoAttackPatternView
@onready var stat_table_view: SpriteInfoStatTableView = $PanelBackground/ContentMargin/Layout/SpriteInfoStatTableView

var _art_textures: Dictionary = {}


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_load_art_textures()


func display_info(info: SpriteInfoData) -> void:
	if info == null:
		clear()
		visible = false
		return

	if _art_textures.is_empty():
		_load_art_textures()

	var rank := info.get_current_rank()
	visible = true
	header_view.refresh(info, rank, _art_textures)
	attack_pattern_view.refresh(info, _art_textures)
	stat_table_view.refresh(rank, _art_textures)
	_apply_panel_art(rank)


func clear() -> void:
	if not is_node_ready():
		return
	header_view.clear()
	attack_pattern_view.clear()
	stat_table_view.clear()
	panel_texture.texture = null
	panel_texture.visible = false
	border_texture.texture = null
	border_texture.visible = false
	fallback_panel.visible = true


func _apply_panel_art(rank: SpriteRankStats) -> void:
	var background := _art_textures.get("背景", null) as Texture2D
	var border := _art_textures.get("%s边框" % _get_quality_key(rank.quality_name), null) as Texture2D
	_set_optional_texture(panel_texture, background)
	_set_optional_texture(border_texture, border)
	fallback_panel.visible = background == null and border == null

	var fallback_style := fallback_panel.get_theme_stylebox("panel") as StyleBoxFlat
	if fallback_style != null:
		fallback_style = fallback_style.duplicate() as StyleBoxFlat
		fallback_style.border_color = rank.quality_color
		fallback_panel.add_theme_stylebox_override("panel", fallback_style)


func _set_optional_texture(texture_rect: TextureRect, texture: Texture2D) -> void:
	texture_rect.texture = texture
	texture_rect.visible = texture != null


func _load_art_textures() -> void:
	_art_textures.clear()
	var directory := DirAccess.open(ART_DIR)
	if directory == null:
		push_warning("Sprite info art directory is unavailable: %s" % ART_DIR)
		return

	directory.list_dir_begin()
	var file_name := directory.get_next()
	while not file_name.is_empty():
		if not directory.current_is_dir() and file_name.get_extension().to_lower() in ["png", "jpg", "jpeg", "webp"]:
			var texture := _load_art_texture("%s/%s" % [ART_DIR, file_name])
			if texture != null:
				var key := file_name.get_basename()
				_art_textures[key] = texture
				if key == "ˮ":
					_art_textures["水"] = texture
		file_name = directory.get_next()
	directory.list_dir_end()


func _load_art_texture(resource_path: String) -> Texture2D:
	if ResourceLoader.exists(resource_path):
		var imported_texture := ResourceLoader.load(resource_path) as Texture2D
		if imported_texture != null:
			return imported_texture

	var image := Image.new()
	if image.load(ProjectSettings.globalize_path(resource_path)) != OK:
		return null
	return ImageTexture.create_from_image(image)


func _get_quality_key(quality_name: String) -> String:
	for key in ["青铜", "白银", "黄金", "钻石"]:
		if quality_name.find(key) != -1:
			return key
	return quality_name.strip_edges()
