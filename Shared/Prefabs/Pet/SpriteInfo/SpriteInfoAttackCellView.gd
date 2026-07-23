@tool
extends PanelContainer
class_name SpriteInfoAttackCellView

@onready var icon: TextureRect = $Icon
@onready var fallback_label: Label = $FallbackLabel


func setup(texture: Texture2D, fallback_text: String, fallback_color: Color) -> void:
	icon.texture = texture
	icon.visible = texture != null
	fallback_label.text = fallback_text
	fallback_label.add_theme_color_override("font_color", fallback_color)
	fallback_label.visible = texture == null and not fallback_text.is_empty()


func clear() -> void:
	icon.texture = null
	icon.visible = false
	fallback_label.text = ""
	fallback_label.visible = false
