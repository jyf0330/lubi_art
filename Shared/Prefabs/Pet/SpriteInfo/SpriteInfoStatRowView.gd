@tool
extends HBoxContainer
class_name SpriteInfoStatRowView

const VALUE_COLUMN_WIDTH := 112.0
const VALUE_MAX_FONT_SIZE := 24
const VALUE_MIN_FONT_SIZE := 10

@export var icon_key := "HP"
@export var display_name := "生命"

@onready var icon: TextureRect = $Icon
@onready var fallback_icon: Label = $FallbackIcon
@onready var name_label: Label = $NameLabel
@onready var value_label: Label = $ValueLabel


func _ready() -> void:
	name_label.text = display_name
	fallback_icon.text = icon_key


func refresh(value: String, art_textures: Dictionary) -> void:
	var texture := art_textures.get(icon_key, null) as Texture2D
	icon.texture = texture
	icon.visible = texture != null
	fallback_icon.text = icon_key
	fallback_icon.visible = texture == null
	name_label.text = display_name
	value_label.text = value
	value_label.add_theme_font_size_override("font_size", _get_value_font_size(value))


func clear() -> void:
	icon.texture = null
	icon.visible = false
	fallback_icon.visible = true
	value_label.text = ""


func _get_value_font_size(value: String) -> int:
	var char_count := maxi(value.length(), 1)
	if char_count <= 5:
		return VALUE_MAX_FONT_SIZE

	var estimated_width_per_char := 15.0
	var fit_size := int(floor(VALUE_COLUMN_WIDTH / (char_count * estimated_width_per_char) * VALUE_MAX_FONT_SIZE))
	return clampi(fit_size, VALUE_MIN_FONT_SIZE, VALUE_MAX_FONT_SIZE)
