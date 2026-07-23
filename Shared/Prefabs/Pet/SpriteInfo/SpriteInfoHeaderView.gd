@tool
extends HBoxContainer
class_name SpriteInfoHeaderView

@onready var element_icon: TextureRect = $ElementBadge/ElementContent/ElementIcon
@onready var element_fallback_label: Label = $ElementBadge/ElementContent/ElementFallbackLabel
@onready var name_label: Label = $NameLabel
@onready var quality_icon: TextureRect = $QualityBadge/QualityContent/QualityIcon
@onready var quality_fallback_label: Label = $QualityBadge/QualityContent/QualityFallbackLabel


func refresh(info: SpriteInfoData, rank: SpriteRankStats, art_textures: Dictionary) -> void:
	name_label.text = info.get_display_name()

	var element_texture := info.element_icon
	if element_texture == null:
		element_texture = art_textures.get(_get_element_key(info.element_name), null) as Texture2D
	_set_optional_texture(element_icon, element_texture)
	element_fallback_label.text = info.element_name
	element_fallback_label.visible = element_texture == null

	var quality_texture := rank.quality_icon
	if quality_texture == null:
		quality_texture = art_textures.get(_get_quality_key(rank.quality_name), null) as Texture2D
	_set_optional_texture(quality_icon, quality_texture)
	quality_fallback_label.text = rank.quality_name
	quality_fallback_label.visible = quality_texture == null


func clear() -> void:
	name_label.text = ""
	element_icon.texture = null
	element_icon.visible = false
	element_fallback_label.text = ""
	element_fallback_label.visible = false
	quality_icon.texture = null
	quality_icon.visible = false
	quality_fallback_label.text = ""
	quality_fallback_label.visible = false


func _set_optional_texture(texture_rect: TextureRect, texture: Texture2D) -> void:
	texture_rect.texture = texture
	texture_rect.visible = texture != null


func _get_quality_key(quality_name: String) -> String:
	for key in ["青铜", "白银", "黄金", "钻石"]:
		if quality_name.find(key) != -1:
			return key
	return quality_name.strip_edges()


func _get_element_key(element_name: String) -> String:
	for key in ["风", "水", "火", "土"]:
		if element_name.find(key) != -1:
			return key
	return element_name.strip_edges()
