extends RefCounted
class_name MockGameData

## Preview-only snapshot shaped after godot-latest GameSession.current_snapshot().
## Values are fake, but public field names and nesting follow the real program
## boundary so a real session snapshot can replace this source later.

const IS_MOCK_DATA := true
const CONTRACT_SOURCE := "/Users/ywh/Documents/godot-latest/scripts/session/game_session.gd"
const BOARD_WIDTH := 8
const BOARD_HEIGHT := 7

const UNITS := [
	{
		"id": "pal_005", "pet_id": "pal_005", "name": "火绒狐", "side": "player",
		"x": 2, "y": 6, "hp": 30, "max_hp": 30, "atk": 5, "def": 0, "shield": 2,
		"ap": 5, "element": "火", "quality": "青铜", "role": "抗压承伤", "active": true,
	},
	{
		"id": "pal_003", "pet_id": "pal_003", "name": "皮皮鸡", "side": "player",
		"x": 3, "y": 6, "hp": 15, "max_hp": 15, "atk": 5, "def": 0, "shield": 0,
		"ap": 4, "element": "风", "quality": "青铜", "role": "削弱远点", "active": true,
	},
	{
		"id": "enemy_r01_001", "pet_id": "enemy_r01_001", "source_pet_id": "pal_001",
		"name": "棉悠悠", "side": "enemy", "x": 3, "y": 2, "hp": 21, "max_hp": 21,
		"atk": 4, "def": 0, "shield": 2, "ap": 3, "element": "风", "quality": "青铜",
		"role": "小怪", "active": true,
	},
	{
		"id": "enemy_r01_002", "pet_id": "enemy_r01_002", "source_pet_id": "pal_042",
		"name": "炽焰牛", "side": "enemy", "x": 4, "y": 1, "hp": 10, "max_hp": 10,
		"atk": 2, "def": 0, "shield": 0, "ap": 3, "element": "火", "quality": "青铜",
		"role": "小怪", "active": true,
	},
	{
		"id": "enemy_r01_003", "pet_id": "enemy_r01_003", "source_pet_id": "pal_077",
		"name": "影龙", "side": "enemy", "x": 3, "y": 0, "hp": 50, "max_hp": 50,
		"atk": 5, "def": 0, "shield": 0, "ap": 3, "element": "水", "quality": "青铜",
		"role": "小怪", "active": true,
	},
]

const LEADERS := {
	"player": {
		"id": "player_hero", "name": "孙悟空", "displayName": "孙悟空", "side": "hero_leader",
		"type": "hero", "x": 0, "y": 6, "position": {"c": 0, "r": 6},
		"hp": 80, "maxHp": 80, "max_hp": 80, "atk": 0, "def": 0, "shield": 0, "alive": true,
	},
	"enemy": {
		"id": "enemy_boss", "name": "虎先锋", "displayName": "虎先锋", "side": "boss",
		"type": "boss", "x": 7, "y": 0, "position": {"c": 7, "r": 0},
		"hp": 80, "maxHp": 80, "max_hp": 80, "atk": 0, "def": 0, "shield": 0, "alive": true,
	},
}

const SHOP_OFFERS := [
	{"id": "shop_001", "offer_id": "shop_001", "pet_id": "pal_001", "name": "棉悠悠", "item_type": "宠物", "price": 2, "default_price": 2, "quality": "青铜", "element": "风", "max_hp": 21, "atk": 4, "shield": 2, "sold": false},
	{"id": "shop_002", "offer_id": "shop_002", "pet_id": "pal_002", "name": "捣蛋猫", "item_type": "宠物", "price": 2, "default_price": 2, "quality": "青铜", "element": "风", "max_hp": 24, "atk": 4, "shield": 1, "sold": false},
	{"id": "shop_003", "offer_id": "shop_003", "pet_id": "pal_003", "name": "皮皮鸡", "item_type": "宠物", "price": 2, "default_price": 2, "quality": "青铜", "element": "风", "max_hp": 15, "atk": 5, "shield": 0, "sold": false},
	{"id": "shop_004", "offer_id": "shop_004", "pet_id": "pal_004", "name": "翠叶鼠", "item_type": "宠物", "price": 2, "default_price": 2, "quality": "青铜", "element": "风", "max_hp": 18, "atk": 5, "shield": 0, "sold": false},
	{"id": "shop_005", "offer_id": "shop_005", "pet_id": "pal_005", "name": "火绒狐", "item_type": "宠物", "price": 2, "default_price": 2, "quality": "青铜", "element": "火", "max_hp": 30, "atk": 3, "shield": 2, "sold": false},
]


static func snapshot() -> Dictionary:
	var units := UNITS.duplicate(true)
	var roster: Array = []
	for unit_value in units:
		var unit := Dictionary(unit_value)
		if String(unit.get("side", "")) == "player":
			var roster_unit := unit.duplicate(true)
			roster_unit["slot"] = roster.size() + 1
			roster_unit["bag_slot"] = 0
			roster.append(roster_unit)
	var snap := {
		"phase": "battle",
		"stateVersion": 1,
		"state_version": 1,
		"stateHash": "mock-preview-snapshot-v1",
		"state_hash": "mock-preview-snapshot-v1",
		"day": 1,
		"node_index": 1,
		"coins": 15,
		"hero_hp": 80,
		"heroMaxHp": 80,
		"hero_max_hp": 80,
		"enemyHeroHp": 80,
		"enemy_hero_hp": 80,
		"enemyHeroMaxHp": 80,
		"enemy_hero_max_hp": 80,
		"ap": 3,
		"battle_round": 1,
		"battle_period": "上午",
		"difficulty": "normal",
		"board_width": BOARD_WIDTH,
		"board_height": BOARD_HEIGHT,
		"boardWidth": BOARD_WIDTH,
		"boardHeight": BOARD_HEIGHT,
		"maxRounds": 12,
		"max_rounds": 12,
		"leaders": LEADERS.duplicate(true),
		"units": units,
		"roster": roster,
		"shop_offers": SHOP_OFFERS.duplicate(true),
		"shop_events": [],
		"route_options": [],
		"reward_options": [],
		"inventory": {"active_count": roster.size(), "bench_count": 0, "max_active": 4, "max_bench": 24},
		"battle_result": {},
		"battleTrace": [],
		"battle_trace": [],
		"nextActions": [],
		"next_actions": [],
		"command_log": [],
		"log_lines": [],
	}
	snap["board"] = _board_snapshot(units, Dictionary(snap["leaders"]))
	snap["viewModel"] = _view_model(snap)
	return snap


static func _board_snapshot(units: Array, leaders: Dictionary) -> Dictionary:
	var occupants := {}
	for unit_value in units:
		var unit := Dictionary(unit_value)
		occupants["%d,%d" % [int(unit.get("x", -1)), int(unit.get("y", -1))]] = unit
	for leader_value in leaders.values():
		var leader := Dictionary(leader_value)
		occupants["%d,%d" % [int(leader.get("x", -1)), int(leader.get("y", -1))]] = leader
	var cells: Array = []
	for y in BOARD_HEIGHT:
		for x in BOARD_WIDTH:
			var key := "%d,%d" % [x, y]
			var occupant := Dictionary(occupants.get(key, {}))
			cells.append({
				"key": key, "x": x, "y": y, "c": x, "r": y,
				"unitId": String(occupant.get("id", "")), "unit_id": String(occupant.get("id", "")),
				"unitName": String(occupant.get("name", "")), "unitSide": String(occupant.get("side", "")),
				"hp": int(occupant.get("hp", 0)), "elements": {}, "trace": {}, "traces": [],
			})
	return {
		"width": BOARD_WIDTH,
		"height": BOARD_HEIGHT,
		"size": BOARD_WIDTH,
		"dimensions": {"width": BOARD_WIDTH, "height": BOARD_HEIGHT},
		"cells": cells,
	}


static func _view_model(snap: Dictionary) -> Dictionary:
	return {
		"phase": String(snap.get("phase", "")),
		"stateVersion": int(snap.get("stateVersion", 0)),
		"stateHash": String(snap.get("stateHash", "")),
		"day": int(snap.get("day", 1)),
		"gold": int(snap.get("coins", 0)),
		"coins": int(snap.get("coins", 0)),
		"heroHp": int(snap.get("hero_hp", 0)),
		"heroMaxHp": int(snap.get("heroMaxHp", 0)),
		"round": int(snap.get("battle_round", 0)),
		"battleRound": int(snap.get("battle_round", 0)),
		"period": String(snap.get("battle_period", "")),
		"leaders": Dictionary(snap.get("leaders", {})).duplicate(true),
		"units": Array(snap.get("units", [])).duplicate(true),
		"board": Dictionary(snap.get("board", {})).duplicate(true),
		"inventory": Dictionary(snap.get("inventory", {})).duplicate(true),
		"shop": {"offers": Array(snap.get("shop_offers", [])).duplicate(true)},
		"battleResult": Dictionary(snap.get("battle_result", {})).duplicate(true),
	}
