@tool
extends Control

@onready var unit_shadow: Control = $UnitShadow
@onready var battle_sprite: Sprite2D = $Sprite
@onready var health_icon: TextureRect = $HealthIcon
@onready var hp_label: Label = $HpLabel
@onready var attack_icon: TextureRect = $AttackIcon
@onready var attack_label: Label = $AttackLabel
@onready var damage_preview_label: Label = $DamagePreviewLabel
@onready var death_mark: Sprite2D = $DeathMarkPreview
@onready var collection_background: TextureRect = $CollectionBackground
@onready var collection_sprite: TextureRect = $CollectionSprite
@onready var collection_frame: TextureRect = $CollectionFrame
@onready var collection_topper: Sprite2D = $CollectionTopper
@onready var status_view: Node = $PetStatusView
@onready var interaction: Node = $PetInteraction

var pet_data: Dictionary = {}
var _display_mode := &"none"


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	interaction.call("configure", self)
	reset_pet_view()


func set_battle_data(data: Dictionary, presentation: Dictionary) -> void:
	reset_pet_view()
	pet_data = data.duplicate(true)
	_display_mode = &"battle"
	size = Vector2(presentation.get("cell_size", size))
	_configure_shadow(presentation)
	_configure_battle_sprite(presentation)
	_configure_stat_badge(health_icon, hp_label, Dictionary(presentation.get("health", {})))
	_configure_stat_badge(attack_icon, attack_label, Dictionary(presentation.get("attack", {})))
	damage_preview_label.position = Vector2(8.0, size.y - 42.0)
	damage_preview_label.size = Vector2(maxf(size.x - 16.0, 0.0), 34.0)
	death_mark.texture = presentation.get("death_mark_texture", null) as Texture2D
	death_mark.position = Vector2(size.x * 0.5, size.y * 0.15)
	death_mark.scale = Vector2(presentation.get("death_mark_scale", Vector2.ONE))
	status_view.call("bind_battle_data", pet_data)
	interaction.call("bind_context", &"battle", String(pet_data.get("team", "")))


func set_collection_data(data: Dictionary, presentation: Dictionary) -> void:
	reset_pet_view()
	pet_data = data.duplicate(true)
	_display_mode = &"collection"
	size = Vector2(presentation.get("slot_size", size))
	collection_background.texture = presentation.get("background_texture", null) as Texture2D
	collection_sprite.texture = presentation.get("sprite_texture", null) as Texture2D
	collection_frame.texture = presentation.get("frame_texture", null) as Texture2D
	collection_frame.position = Vector2(presentation.get("frame_position", Vector2.ZERO))
	collection_frame.size = Vector2(presentation.get("frame_size", size))
	collection_topper.texture = presentation.get("topper_texture", null) as Texture2D
	collection_topper.position = Vector2(presentation.get("topper_position", Vector2(size.x * 0.5, 0.0)))
	collection_topper.scale = Vector2(presentation.get("topper_scale", Vector2.ONE))
	collection_background.visible = collection_background.texture != null
	collection_sprite.visible = collection_sprite.texture != null
	collection_frame.visible = collection_frame.texture != null
	collection_topper.visible = collection_topper.texture != null
	interaction.call("bind_context", &"collection", "player")


func clear_collection_data() -> void:
	reset_pet_view()
	_display_mode = &"collection"


func reset_pet_view() -> void:
	pet_data = {}
	_display_mode = &"none"
	unit_shadow.visible = false
	battle_sprite.visible = false
	health_icon.visible = false
	hp_label.visible = false
	attack_icon.visible = false
	attack_label.visible = false
	damage_preview_label.visible = false
	death_mark.visible = false
	collection_background.visible = false
	collection_sprite.visible = false
	collection_frame.visible = false
	collection_topper.visible = false
	collection_background.texture = null
	collection_sprite.texture = null
	collection_frame.texture = null
	collection_topper.texture = null
	status_view.call("reset")
	interaction.call("reset")


func get_display_mode() -> StringName:
	return _display_mode


func get_display_texture() -> Texture2D:
	if _display_mode == &"collection":
		return collection_sprite.texture
	return battle_sprite.texture


func update_hp(value: int) -> void:
	pet_data["hp"] = value
	status_view.call("update_hp", value)


func update_attack(value: int) -> void:
	pet_data["attack_damage"] = value
	status_view.call("update_attack", value)


func show_health_preview(damage: int, color: Color) -> void:
	var preview_hp := maxi(0, int(pet_data.get("hp", 0)) - maxi(0, damage))
	status_view.call("show_hp_preview", preview_hp, color)


func show_damage_preview(
	damage: int,
	color: Color,
	alignment: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT
) -> void:
	status_view.call("show_damage_preview", maxi(0, damage), damage > 0, color, alignment)


func show_death_preview(texture: Texture2D, preview_scale: Vector2) -> void:
	death_mark.texture = texture
	death_mark.scale = preview_scale
	death_mark.visible = texture != null


func clear_combat_preview() -> void:
	status_view.call("clear_preview")
	death_mark.visible = false


func set_visual_tint(color: Color) -> void:
	modulate = color


func set_selected(selected: bool) -> void:
	interaction.call("set_selected", selected)


func set_dragging(dragging: bool) -> void:
	interaction.call("set_dragging", dragging)


func _configure_shadow(presentation: Dictionary) -> void:
	var shadow_size := Vector2(presentation.get("shadow_size", Vector2.ZERO))
	unit_shadow.position = Vector2(presentation.get("shadow_position", Vector2.ZERO))
	unit_shadow.scale = Vector2(presentation.get("shadow_scale", Vector2.ONE))
	unit_shadow.visible = shadow_size != Vector2.ZERO


func _configure_battle_sprite(presentation: Dictionary) -> void:
	battle_sprite.texture = presentation.get("sprite_texture", null) as Texture2D
	battle_sprite.position = Vector2(presentation.get("sprite_position", size * 0.5))
	battle_sprite.scale = Vector2(presentation.get("sprite_scale", Vector2.ONE))
	battle_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST if bool(presentation.get("pixel_art", false)) else CanvasItem.TEXTURE_FILTER_LINEAR
	battle_sprite.visible = battle_sprite.texture != null


func _configure_stat_badge(icon: TextureRect, label: Label, badge: Dictionary) -> void:
	icon.texture = badge.get("texture", null) as Texture2D
	icon.position = Vector2(badge.get("icon_position", Vector2.ZERO))
	icon.size = Vector2(badge.get("icon_size", Vector2.ZERO))
	icon.visible = icon.texture != null
	label.position = Vector2(badge.get("label_position", Vector2.ZERO))
	label.size = Vector2(badge.get("label_size", Vector2.ZERO))
	label.visible = icon.visible
