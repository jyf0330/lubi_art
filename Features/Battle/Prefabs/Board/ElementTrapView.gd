@tool
extends Node2D
class_name ElementTrapView

@onready var trap_sprite: Sprite2D = $TrapSprite
@onready var damage_label: Label = $DamageLabel

var _damage := 0


func setup(view_model: Dictionary) -> void:
	_damage = maxi(0, int(view_model.get("damage", 0)))
	var cell_size := Vector2(view_model.get("cell_size", Vector2.ZERO))
	trap_sprite.texture = view_model.get("texture", null) as Texture2D
	trap_sprite.scale = Vector2(view_model.get("sprite_scale", Vector2.ONE))
	trap_sprite.modulate = Color(1.0, 1.0, 1.0, 0.82)
	damage_label.position = Vector2(cell_size.x * 0.5 - 42.0, 8.0 - cell_size.y * 0.5)
	_refresh_damage_label()


func refresh(view_model: Dictionary) -> void:
	setup(view_model)


func add_damage(amount: int) -> int:
	_damage = maxi(0, _damage + amount)
	_refresh_damage_label()
	return _damage


func get_damage() -> int:
	return _damage


func _refresh_damage_label() -> void:
	damage_label.text = str(_damage)
