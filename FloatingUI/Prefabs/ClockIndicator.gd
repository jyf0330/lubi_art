@tool
extends Node2D
class_name ClockIndicatorView

@export_range(1, 24, 1) var hours_per_day := 6
@export_range(0.05, 2.0, 0.01) var advance_duration := 0.38

const DIAL_IMAGE_SIZE := Vector2(220.0, 220.0)
const DIAL_CENTER := Vector2(110.12, 103.40)
const DIAL_RADIUS := 57.63
const HOLE_POINTS := [
	Vector2(111.05, 44.91),
	Vector2(158.25, 72.98),
	Vector2(160.35, 131.93),
	Vector2(110.18, 161.23),
	Vector2(60.18, 132.11),
	Vector2(61.75, 72.98),
]
const POINTER_PIVOT := Vector2(54.52, 72.15)
const POINTER_HOLE := Vector2(100.69, 37.58)
const HIGHLIGHT_SIZE := Vector2(22.0, 22.0)
const DAY_LABEL_SIZE := Vector2(56.0, 44.0)

@onready var _dial: Sprite2D = $Dial
@onready var _pointer: Sprite2D = $Pointer
@onready var _day_label: Label = $DayLabel
@onready var _highlights: Array[Sprite2D] = [
	$ActiveHourDot1,
	$ActiveHourDot2,
	$ActiveHourDot3,
	$ActiveHourDot4,
	$ActiveHourDot5,
]

var _display_size := 155.0
var _slot_angles: Array[float] = []
var _pointer_default_angle := 0.0
var _tween: Tween = null
var _pending_total_hours := 0
var _pending_animate := false


func _ready() -> void:
	_layout_art()
	set_total_hours(_pending_total_hours, _pending_animate)


func setup(total_hours: int, display_size := 155.0, animate := false) -> void:
	_display_size = display_size
	_pending_total_hours = max(0, total_hours)
	_pending_animate = animate
	if is_node_ready():
		_layout_art()
		set_total_hours(_pending_total_hours, animate)


func set_total_hours(total_hours: int, animate := false) -> void:
	_pending_total_hours = max(0, total_hours)
	_pending_animate = animate
	if not is_node_ready():
		return

	var target_rotation := _rotation_for_total_hour(_pending_total_hours)
	if _tween != null:
		_tween.kill()
		_tween = null
	if animate:
		_tween = create_tween()
		_tween.set_trans(Tween.TRANS_SINE)
		_tween.set_ease(Tween.EASE_IN_OUT)
		_tween.tween_property(_pointer, "rotation", target_rotation, advance_duration)
	else:
		_pointer.rotation = target_rotation

	var hour := _pending_total_hours % hours_per_day
	var day := int(_pending_total_hours / hours_per_day) + 1
	_day_label.text = str(day)
	for index in _highlights.size():
		_highlights[index].visible = hour >= index + 1


func _layout_art() -> void:
	var dial_scale := _display_size / DIAL_IMAGE_SIZE.x
	_dial.scale = Vector2.ONE * dial_scale
	_pointer_default_angle = (POINTER_HOLE - POINTER_PIVOT).angle()
	_slot_angles = _build_slot_angles()
	var pointer_scale := (DIAL_RADIUS * dial_scale) / (POINTER_HOLE - POINTER_PIVOT).length()
	_pointer.offset = -POINTER_PIVOT
	_pointer.position = _scene_point(DIAL_CENTER)
	_pointer.scale = Vector2.ONE * pointer_scale

	for index in _highlights.size():
		var highlight := _highlights[index]
		var texture_size := highlight.texture.get_size()
		var target_size := HIGHLIGHT_SIZE * dial_scale
		highlight.scale = Vector2(target_size.x / texture_size.x, target_size.y / texture_size.y)
		highlight.position = _scene_point(HOLE_POINTS[index + 1])

	var label_size := DAY_LABEL_SIZE * dial_scale
	_day_label.size = label_size
	_day_label.position = _scene_point(HOLE_POINTS[0]) - label_size * 0.5
	_day_label.add_theme_font_size_override("font_size", int(round(30.0 * dial_scale)))


func _build_slot_angles() -> Array[float]:
	var angles: Array[float] = []
	var previous_angle := -INF
	for hole_point in HOLE_POINTS:
		var angle: float = (hole_point - DIAL_CENTER).angle()
		while angle <= previous_angle:
			angle += TAU
		angles.append(angle)
		previous_angle = angle
	return angles


func _scene_point(dial_point: Vector2) -> Vector2:
	return dial_point * (_display_size / DIAL_IMAGE_SIZE.x)


func _rotation_for_total_hour(total_hours: int) -> float:
	if _slot_angles.is_empty():
		return 0.0
	var hour := total_hours % hours_per_day
	var day_cycles := int(total_hours / hours_per_day)
	return _slot_angles[hour] + float(day_cycles) * TAU - _pointer_default_angle
