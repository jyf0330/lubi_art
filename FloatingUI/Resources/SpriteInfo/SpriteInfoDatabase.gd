extends Resource
class_name SpriteInfoDatabase

const ELEMENT_PROFILES := [
	{"name": "风属性", "color": Color(0.16, 0.65, 0.48, 1.0)},
	{"name": "火属性", "color": Color(0.82, 0.22, 0.14, 1.0)},
	{"name": "水属性", "color": Color(0.16, 0.48, 0.86, 1.0)},
	{"name": "土属性", "color": Color(0.52, 0.38, 0.18, 1.0)},
]

const QUALITY_PROFILES := [
	{"name": "青铜", "color": Color(0.55, 0.32, 0.18, 1.0), "level": 0},
	{"name": "白银", "color": Color(0.68, 0.70, 0.72, 1.0), "level": 1},
	{"name": "黄金", "color": Color(0.95, 0.62, 0.08, 1.0), "level": 2},
	{"name": "钻石", "color": Color(0.45, 0.72, 1.0, 1.0), "level": 3},
]
const ATTACK_GRID_COLUMNS := 7
const ATTACK_GRID_ROWS := 3
const ATTACK_ORIGIN_INDEX := 10


func get_info_for_texture(_sprite_texture: Texture2D) -> SpriteInfoData:
	# The old per-sprite .tres binding mode is intentionally disabled.
	# Hover info now uses generated placeholder data from make_default_info().
	return null


func make_default_info(sprite_texture: Texture2D) -> SpriteInfoData:
	var info := SpriteInfoData.new()
	var rng := RandomNumberGenerator.new()
	rng.seed = _make_seed_from_texture(sprite_texture)

	info.sprite_texture = sprite_texture
	info.sprite_id = _make_id_from_texture(sprite_texture)
	info.display_name = _make_name_from_texture(sprite_texture)
	info.current_rank_index = 0

	var element_profile: Dictionary = ELEMENT_PROFILES[rng.randi_range(0, ELEMENT_PROFILES.size() - 1)]
	info.element_name = element_profile["name"]
	info.element_color = element_profile["color"]

	info.attack_cell_count = ATTACK_GRID_COLUMNS * ATTACK_GRID_ROWS
	info.origin_cell_index = ATTACK_ORIGIN_INDEX
	info.hit_cell_indices = _make_random_hit_indices(rng, info.attack_cell_count, info.origin_cell_index)

	var quality_profile: Dictionary = QUALITY_PROFILES[rng.randi_range(0, QUALITY_PROFILES.size() - 1)]
	info.ranks.append(_make_random_rank(rng, quality_profile))
	return info


func _make_random_rank(rng: RandomNumberGenerator, quality_profile: Dictionary) -> SpriteRankStats:
	var rank := SpriteRankStats.new()
	var level := int(quality_profile["level"])
	rank.quality_name = quality_profile["name"]
	rank.quality_color = quality_profile["color"]
	rank.hp_max = rng.randi_range(16, 24) + level * 6
	rank.hp_current = rank.hp_max
	rank.ap_max = rng.randi_range(2, 4)
	rank.ap_current = rank.ap_max
	rank.attack = rng.randi_range(3, 6) + level * 2
	rank.defense = rng.randi_range(0, 3) + level
	rank.shield = rng.randi_range(0, 4) + level
	rank.regen = rng.randi_range(0, 2) + int(floor(level / 2.0))
	return rank


func _make_random_hit_indices(rng: RandomNumberGenerator, cell_count: int, origin_index: int) -> Array[int]:
	var hits: Array[int] = []
	var candidates: Array[int] = []
	for index in cell_count:
		if index != origin_index:
			candidates.append(index)

	if candidates.is_empty():
		return hits

	var max_hits: int = candidates.size()
	if max_hits > 5:
		max_hits = 5

	var hit_count: int = rng.randi_range(1, max_hits)
	for index in hit_count:
		var candidate_index: int = rng.randi_range(0, candidates.size() - 1)
		var hit_cell: int = int(candidates[candidate_index])
		hits.append(hit_cell)
		candidates.remove_at(candidate_index)

	return hits


func _make_name_from_texture(sprite_texture: Texture2D) -> String:
	if sprite_texture == null:
		return "未命名精灵"

	var sprite_id := _make_id_from_texture(sprite_texture)
	if not sprite_id.is_empty():
		return sprite_id

	var base_name := sprite_texture.resource_path.get_file().get_basename()
	return base_name.replace("Sprite_", "")


func _make_id_from_texture(sprite_texture: Texture2D) -> String:
	if sprite_texture == null:
		return ""

	var base_name := sprite_texture.resource_path.get_file().get_basename()
	if not base_name.begins_with("Sprite_"):
		return ""

	var candidate := base_name.substr("Sprite_".length())
	if candidate.is_valid_int():
		return candidate

	return ""


func _make_seed_from_texture(sprite_texture: Texture2D) -> int:
	if sprite_texture == null:
		return 1

	var seed_text := sprite_texture.resource_path
	if seed_text.is_empty():
		seed_text = str(sprite_texture.get_instance_id())

	return seed_text.hash()
