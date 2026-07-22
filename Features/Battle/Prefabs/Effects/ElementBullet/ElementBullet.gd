@tool
extends Sprite2D
class_name ElementBulletView


func setup(projectile_texture: Texture2D, start_position: Vector2) -> void:
	texture = projectile_texture
	position = start_position


func play(target_position: Vector2, duration := 0.32, min_arc_height := 72.0, distance_scale := 0.32) -> void:
	var start_position := position
	var arc_height: float = max(min_arc_height, start_position.distance_to(target_position) * distance_scale)
	rotation = _arc_tangent(start_position, target_position, arc_height, 0.0).angle()
	var tween := create_tween()
	tween.tween_method(
		func(progress: float) -> void:
			position = _arc_position(start_position, target_position, arc_height, progress)
			rotation = _arc_tangent(start_position, target_position, arc_height, progress).angle(),
		0.0,
		1.0,
		duration
	)
	tween.tween_callback(queue_free)


func _arc_position(start_position: Vector2, target_position: Vector2, arc_height: float, progress: float) -> Vector2:
	return start_position.lerp(target_position, progress) + Vector2.UP * sin(progress * PI) * arc_height


func _arc_tangent(start_position: Vector2, target_position: Vector2, arc_height: float, progress: float) -> Vector2:
	return target_position - start_position + Vector2.UP * cos(progress * PI) * PI * arc_height
