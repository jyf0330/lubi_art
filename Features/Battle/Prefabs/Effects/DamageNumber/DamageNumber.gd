@tool
extends Label
class_name DamageNumberView

@export var rise_distance := 34.0
@export var animation_duration := 0.65


func setup(amount: int) -> void:
	text = "-%d" % max(0, amount)


func play() -> void:
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "position", position + Vector2.UP * rise_distance, animation_duration)
	tween.tween_property(self, "modulate:a", 0.0, animation_duration)
	tween.set_parallel(false)
	tween.tween_callback(queue_free)
