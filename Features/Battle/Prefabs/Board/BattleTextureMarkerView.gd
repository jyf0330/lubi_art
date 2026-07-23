@tool
extends TextureRect
class_name BattleTextureMarkerView


func setup(view_model: Dictionary) -> void:
	texture = view_model.get("texture", null) as Texture2D
	size = Vector2(view_model.get("size", size))
	position = Vector2(view_model.get("position", position))
	custom_minimum_size = Vector2.ZERO
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stretch_mode = TextureRect.STRETCH_SCALE
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = int(view_model.get("z_index", z_index))
	visible = bool(view_model.get("visible", true)) and texture != null


func refresh(view_model: Dictionary) -> void:
	setup(view_model)


func show_at(marker_position: Vector2, marker_size: Vector2, is_visible: bool) -> void:
	position = marker_position
	size = marker_size
	visible = is_visible and texture != null
