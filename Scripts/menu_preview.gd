@tool
extends Control


func _ready() -> void:
	queue_redraw()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()


func _draw() -> void:
	# A restrained dark wood/metal backdrop keeps the button close to the reference
	# while leaving the button itself fully reusable.
	draw_rect(Rect2(Vector2.ZERO, size), Color("#160b08"))
	var centre_y := size.y * 0.5
	for offset in [-52.0, -44.0, 44.0, 52.0]:
		draw_line(Vector2(0, centre_y + offset), Vector2(size.x, centre_y + offset), Color("#3d210e"), 7.0, true)
		draw_line(Vector2(0, centre_y + offset - 2.0), Vector2(size.x, centre_y + offset - 2.0), Color("#9a5b18"), 1.0, true)
		draw_line(Vector2(0, centre_y + offset + 2.0), Vector2(size.x, centre_y + offset + 2.0), Color("#080505"), 2.0, true)
