@tool
extends Control
class_name CollectionPetView

var background: TextureRect
var creature: TextureRect
var frame: TextureRect
var topper: Sprite2D
var merge_clip: Control
var merge_indicator: TextureRect
var merge_follower: TextureRect

var _indicator_tween: Tween


func _ready() -> void:
	_bind_nodes()


func setup(view_model: Dictionary) -> void:
	_bind_nodes()
	var slot_size := Vector2(view_model.get("slot_size", size))
	size = slot_size
	background.size = slot_size
	creature.size = slot_size
	background.texture = view_model.get("background_texture", null) as Texture2D
	creature.texture = view_model.get("sprite_texture", null) as Texture2D
	frame.texture = view_model.get("frame_texture", null) as Texture2D
	frame.position = Vector2(view_model.get("frame_position", Vector2.ZERO))
	frame.size = Vector2(view_model.get("frame_size", slot_size))
	topper.texture = view_model.get("topper_texture", null) as Texture2D
	topper.position = Vector2(view_model.get("topper_position", Vector2(slot_size.x * 0.5, 0.0)))
	topper.scale = Vector2(view_model.get("topper_scale", Vector2.ONE))
	background.visible = background.texture != null
	creature.visible = creature.texture != null
	frame.visible = frame.texture != null
	topper.visible = topper.texture != null


func refresh(view_model: Dictionary) -> void:
	setup(view_model)


func clear() -> void:
	_bind_nodes()
	background.texture = null
	creature.texture = null
	frame.texture = null
	topper.texture = null
	background.visible = false
	creature.visible = false
	frame.visible = false
	topper.visible = false
	set_merge_indicator(null, 0.0, false)


func get_display_texture() -> Texture2D:
	_bind_nodes()
	return creature.texture


func get_presentation_snapshot() -> Dictionary:
	_bind_nodes()
	return {
		"frame_position": frame.position,
		"frame_size": frame.size,
		"topper_scale": topper.scale,
	}


func set_frame_presentation(
	texture: Texture2D,
	frame_position: Vector2,
	frame_size: Vector2,
	topper_scale: Vector2
) -> void:
	_bind_nodes()
	frame.texture = texture
	frame.position = frame_position
	frame.size = frame_size
	frame.visible = texture != null
	topper.scale = topper_scale


func set_merge_indicator(texture: Texture2D, opacity: float, is_visible: bool) -> void:
	_bind_nodes()
	merge_indicator.texture = texture
	merge_follower.texture = texture
	merge_indicator.modulate = Color(1.0, 1.0, 1.0, clampf(opacity, 0.0, 1.0))
	merge_clip.visible = is_visible and texture != null
	if merge_clip.visible:
		_start_indicator_animation()
	elif _indicator_tween != null:
		_indicator_tween.kill()
		_indicator_tween = null


func _bind_nodes() -> void:
	if background != null:
		return
	background = get_node("Background") as TextureRect
	creature = get_node("Creature") as TextureRect
	frame = get_node("Frame") as TextureRect
	topper = get_node("Topper") as Sprite2D
	merge_clip = get_node("MergeIndicatorClip") as Control
	merge_indicator = get_node("MergeIndicatorClip/Indicator") as TextureRect
	merge_follower = get_node("MergeIndicatorClip/Indicator/Follower") as TextureRect


func _start_indicator_animation() -> void:
	if _indicator_tween != null and _indicator_tween.is_valid():
		return
	merge_indicator.position = Vector2.ZERO
	_indicator_tween = merge_indicator.create_tween().set_loops()
	_indicator_tween.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	_indicator_tween.tween_property(merge_indicator, "position:y", -size.y, 1.15).from(0.0)
