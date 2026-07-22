extends RefCounted
class_name MockGameData

## Centralized placeholder data. Replace this source with a real provider later;
## controllers and art prefabs should not need to change.

const IS_MOCK_DATA := true

const BATTLE_DATA := {
	"defaults": {
		"player_max_hp": 10,
		"player_attack_damage": 5,
		"enemy_max_hp": 5,
		"enemy_attack_damage": 1,
		"enemy_attack_range": 1,
		"enemy_move_distance": 1,
	},
	"player_attack_directions": [Vector2i.RIGHT, Vector2i.UP, Vector2i.LEFT],
	"player_attack_distances": [2, 3],
	"hero_barrage_bullets_per_attacker": 4,
	"hero_barrage_max_volleys": 64,
	"starting_units": [
		{"coord": "7a", "team": "player", "element": "fire", "sprite_path": "res://Features/Battle/Art/Heroes/sun_wukong_ai_220x210.png", "hp": 100, "max_hp": 100, "attack_damage": 0, "move_distance": 0, "movable": false, "is_hero": true},
		{"coord": "1h", "team": "enemy", "element": "water", "sprite_path": "res://Features/Battle/Art/Heroes/spider_spirit_ai_220x210.png", "hp": 100, "max_hp": 100, "attack_damage": 0, "move_distance": 0, "movable": false, "is_hero": true},
		{"coord": "7c", "team": "player", "element": "fire", "sprite_path": "res://Features/Battle/Art/Units/Sprite_FlameCub.png", "pixel_art": true},
		{"coord": "7d", "team": "player", "element": "fire", "sprite_path": "res://Features/Battle/Art/Units/Sprite_FireLion.png", "pixel_art": true},
		{"coord": "3d", "team": "enemy", "element": "water"},
		{"coord": "2e", "team": "enemy", "element": "water"},
		{"coord": "1d", "team": "enemy", "element": "water", "sprite_path": "res://Features/Battle/Art/Units/Sprite_ShadowDragon.png", "hp": 50, "max_hp": 50, "attack_damage": 5, "move_distance": 3},
	],
}

const SHOP_DATA := {
	"initial_gold": 15,
	"buy_price": 2,
	"sell_price": 1,
	"creature_catalog_dir": "res://Features/ArtistFlow/Art/Pets/Sprites",
	"shop_boss_image_dir": "res://Features/ArtistFlow/Art/Shop/Bosses",
	"featured_creature_path": "res://Features/ArtistFlow/Art/Pets/Sprites/Sprite_WhiteFox.png",
	"quality_order": [&"bronze", &"silver", &"gold", &"diamond"],
}


static func battle_data() -> Dictionary:
	return BATTLE_DATA.duplicate(true)


static func shop_data() -> Dictionary:
	return SHOP_DATA.duplicate(true)

