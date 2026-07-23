extends TextureRect
class_name MergeBurstView


func setup(view_model: Dictionary) -> void:
	texture = view_model.get("texture", null) as Texture2D
	size = Vector2(view_model.get("size", Vector2(360.0, 360.0)))
	pivot_offset = size * 0.5
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	modulate = Color(1.0, 1.0, 1.0, 0.0)
	scale = Vector2.ONE * float(view_model.get("initial_scale", 0.18))


func refresh(view_model: Dictionary) -> void:
	setup(view_model)
