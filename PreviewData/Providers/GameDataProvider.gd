extends RefCounted
class_name GameDataProvider

## Presentation adapter for the same snapshot boundary used by godot-latest.
## Only this adapter knows how snapshot fields map onto the art preview's
## temporary battle driver and texture resources.

const MOCK_SOURCE := preload("res://PreviewData/Mock/MockGameData.gd")
const FILE_LABELS := "abcdefgh"
const BATTLE_PREVIEW_RULES := {
	"player_attack_directions": [Vector2i.RIGHT, Vector2i.UP, Vector2i.LEFT],
	"player_attack_distances": [2, 3],
	"enemy_attack_range": 1,
	"enemy_move_distance": 1,
	"hero_barrage_bullets_per_attacker": 4,
	"hero_barrage_max_volleys": 64,
}
const PRESENTATION := {
	"creature_catalog_dir": "res://Shared/Art/Pets/Sprites",
	"shop_boss_image_dir": "res://Features/ArtistFlow/Art/Shop/Bosses",
	"pet_sprites": {
		"pal_001": "res://Shared/Art/Pets/Sprites/Sprite_CloudPuff.png",
		"pal_002": "res://Shared/Art/Pets/Sprites/Sprite_GrayCat.png",
		"pal_003": "res://Shared/Art/Pets/Sprites/Sprite_BrownSparrow.png",
		"pal_004": "res://Shared/Art/Pets/Sprites/Sprite_LeafCub.png",
		"pal_005": "res://Shared/Art/Pets/Sprites/Sprite_WhiteFox.png",
		"pal_042": "res://Shared/Art/Pets/Sprites/Sprite_FireLion.png",
		"pal_077": "res://Shared/Art/Pets/Sprites/Sprite_ShadowDragon.png",
	},
	"leader_sprites": {
		"player_hero": "res://Shared/Art/Heroes/sun_wukong_ai_220x210.png",
		"enemy_boss": "res://Shared/Art/Heroes/spider_spirit_ai_220x210.png",
	},
}

var _snapshot_override: Dictionary = {}


func is_using_mock_data() -> bool:
	return MOCK_SOURCE.IS_MOCK_DATA


func get_snapshot() -> Dictionary:
	if not _snapshot_override.is_empty():
		return _snapshot_override.duplicate(true)
	return MOCK_SOURCE.snapshot()


func set_snapshot(snapshot: Dictionary) -> void:
	_snapshot_override = snapshot.duplicate(true)


func clear_snapshot_override() -> void:
	_snapshot_override.clear()


func get_view_model() -> Dictionary:
	return Dictionary(get_snapshot().get("viewModel", {})).duplicate(true)


func get_battle_preview_rules() -> Dictionary:
	return BATTLE_PREVIEW_RULES.duplicate(true)


func get_battle_data() -> Dictionary:
	var snapshot := get_snapshot()
	var rules := get_battle_preview_rules()
	var player_leader := Dictionary(Dictionary(snapshot.get("leaders", {})).get("player", {}))
	var enemy_units := _units_for_side(snapshot, "enemy")
	var first_enemy := Dictionary(enemy_units[0]) if not enemy_units.is_empty() else {}
	return {
		"snapshot": snapshot,
		"defaults": {
			"player_max_hp": int(player_leader.get("max_hp", 10)),
			"player_attack_damage": 5,
			"enemy_max_hp": int(first_enemy.get("max_hp", 5)),
			"enemy_attack_damage": int(first_enemy.get("atk", 1)),
			"enemy_attack_range": int(rules.get("enemy_attack_range", 1)),
			"enemy_move_distance": int(rules.get("enemy_move_distance", 1)),
		},
		"player_attack_directions": rules["player_attack_directions"],
		"player_attack_distances": rules["player_attack_distances"],
		"hero_barrage_bullets_per_attacker": rules["hero_barrage_bullets_per_attacker"],
		"hero_barrage_max_volleys": rules["hero_barrage_max_volleys"],
	}


func get_battle_units() -> Array[Dictionary]:
	var snapshot := get_snapshot()
	var result: Array[Dictionary] = []
	var leaders := Dictionary(snapshot.get("leaders", {}))
	_append_battle_unit(result, Dictionary(leaders.get("player", {})), "player", true)
	_append_battle_unit(result, Dictionary(leaders.get("enemy", {})), "enemy", true)
	for raw_unit in Array(snapshot.get("units", [])):
		var unit := Dictionary(raw_unit)
		_append_battle_unit(result, unit, String(unit.get("side", "enemy")), false)
	return result


func get_shop_data() -> Dictionary:
	var snapshot := get_snapshot()
	var offers: Array[Dictionary] = []
	for raw_offer in Array(snapshot.get("shop_offers", [])):
		var offer := Dictionary(raw_offer).duplicate(true)
		offer["texture_path"] = _pet_sprite_path(String(offer.get("pet_id", "")))
		offer["preview_quality"] = _preview_quality(String(offer.get("quality", "青铜")))
		offers.append(offer)
	return {
		"snapshot": snapshot,
		"initial_gold": int(snapshot.get("coins", 0)),
		"sell_price": 1,
		"creature_catalog_dir": String(PRESENTATION["creature_catalog_dir"]),
		"shop_boss_image_dir": String(PRESENTATION["shop_boss_image_dir"]),
		"quality_order": [&"bronze", &"silver", &"gold", &"diamond"],
		"offers": offers,
	}


func _append_battle_unit(result: Array[Dictionary], source: Dictionary, team: String, is_hero: bool) -> void:
	if source.is_empty():
		return
	var x := int(source.get("x", Dictionary(source.get("position", {})).get("c", -1)))
	var y := int(source.get("y", Dictionary(source.get("position", {})).get("r", -1)))
	if x < 0 or x >= FILE_LABELS.length() or y < 0:
		return
	var source_id := String(source.get("source_pet_id", source.get("pet_id", source.get("id", ""))))
	var sprite_path := _leader_sprite_path(String(source.get("id", ""))) if is_hero else _pet_sprite_path(source_id)
	var unit := {
		"id": String(source.get("id", "")),
		"pet_id": String(source.get("pet_id", "")),
		"name": String(source.get("name", "")),
		"coord": "%d%s" % [y + 1, FILE_LABELS.substr(x, 1)],
		"team": team,
		"element": _preview_element(String(source.get("element", ""))),
		"hp": int(source.get("hp", 1)),
		"max_hp": int(source.get("max_hp", source.get("maxHp", source.get("hp", 1)))),
		"attack_damage": int(source.get("atk", 0)),
		"move_distance": 0 if is_hero else int(source.get("move_distance", 3 if team == "enemy" else 1)),
		"movable": not is_hero,
		"is_hero": is_hero,
		"pixel_art": not is_hero,
	}
	if not sprite_path.is_empty():
		var sprite := load(sprite_path) as Texture2D
		if sprite != null:
			unit["sprite"] = sprite
		else:
			push_warning("Preview sprite is missing: %s" % sprite_path)
	result.append(unit)


func _units_for_side(snapshot: Dictionary, side: String) -> Array:
	var result: Array = []
	for raw_unit in Array(snapshot.get("units", [])):
		var unit := Dictionary(raw_unit)
		if String(unit.get("side", "")) == side:
			result.append(unit)
	return result


func _pet_sprite_path(pet_id: String) -> String:
	return String(Dictionary(PRESENTATION["pet_sprites"]).get(pet_id, ""))


func _leader_sprite_path(leader_id: String) -> String:
	return String(Dictionary(PRESENTATION["leader_sprites"]).get(leader_id, ""))


func _preview_element(element: String) -> String:
	return {"火": "fire", "水": "water", "土": "earth", "风": "wind"}.get(element, "water")


func _preview_quality(quality: String) -> StringName:
	return StringName({"青铜": "bronze", "白银": "silver", "黄金": "gold", "钻石": "diamond"}.get(quality, quality))
