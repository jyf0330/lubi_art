extends RefCounted
class_name GameDataProvider

## Stable data gateway used by controller/adapter code.
## Swap MOCK_SOURCE for a server/save-backed source when real data is ready.

const MOCK_SOURCE := preload("res://Data/MockGameData.gd")


func is_using_mock_data() -> bool:
	return MOCK_SOURCE.IS_MOCK_DATA


func get_battle_data() -> Dictionary:
	return MOCK_SOURCE.battle_data()


func get_battle_units() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for raw_unit in get_battle_data().get("starting_units", []):
		var unit := (raw_unit as Dictionary).duplicate(true)
		var sprite_path := String(unit.get("sprite_path", ""))
		if not sprite_path.is_empty():
			var sprite := load(sprite_path) as Texture2D
			if sprite != null:
				unit["sprite"] = sprite
			else:
				push_warning("Mock battle sprite is missing: %s" % sprite_path)
		unit.erase("sprite_path")
		result.append(unit)
	return result


func get_shop_data() -> Dictionary:
	return MOCK_SOURCE.shop_data()

