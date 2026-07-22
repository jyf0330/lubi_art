extends RefCounted
class_name GameSessionStore

## Owns local persistence. Controllers request state through this gateway and
## remain unaware of file paths, ConfigFile sections, and serialization keys.

const GOLD_STATE_PATH := "user://three_option_shared_state.cfg"
const GOLD_STATE_SECTION := "player"
const GOLD_STATE_KEY := "gold"
const CLOCK_STATE_PATH := "user://three_option_clock_state.cfg"
const CLOCK_STATE_SECTION := "clock"
const CLOCK_TOTAL_HOURS_KEY := "total_hours"
const CLOCK_HOUR_KEY := "hour"
const CLOCK_DAY_KEY := "day"
const STORAGE_STATE_PATH := "user://three_option_storage_state.cfg"
const STORAGE_PARTY_SECTION := "party"
const STORAGE_BAG_SECTION := "bag"
const STORAGE_ITEM_TEXTURE_KEY_FORMAT := "slot_%d_texture"
const STORAGE_ITEM_QUALITY_KEY_FORMAT := "slot_%d_quality"


func load_gold(default_value: int) -> int:
	var config := ConfigFile.new()
	if config.load(GOLD_STATE_PATH) != OK:
		return max(0, default_value)
	return max(0, int(config.get_value(GOLD_STATE_SECTION, GOLD_STATE_KEY, default_value)))


func save_gold(value: int) -> Error:
	var config := ConfigFile.new()
	config.set_value(GOLD_STATE_SECTION, GOLD_STATE_KEY, max(0, value))
	return config.save(GOLD_STATE_PATH)


func load_clock_total_hours(default_value := 0) -> int:
	var config := ConfigFile.new()
	if config.load(CLOCK_STATE_PATH) != OK:
		return max(0, default_value)
	return max(0, int(config.get_value(CLOCK_STATE_SECTION, CLOCK_TOTAL_HOURS_KEY, default_value)))


func save_clock(total_hours: int, hour: int, day: int) -> Error:
	var config := ConfigFile.new()
	config.set_value(CLOCK_STATE_SECTION, CLOCK_TOTAL_HOURS_KEY, max(0, total_hours))
	config.set_value(CLOCK_STATE_SECTION, CLOCK_HOUR_KEY, max(0, hour))
	config.set_value(CLOCK_STATE_SECTION, CLOCK_DAY_KEY, max(1, day))
	return config.save(CLOCK_STATE_PATH)


func load_storage(section: StringName, slot_count: int, default_quality: StringName) -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	var config := ConfigFile.new()
	if config.load(STORAGE_STATE_PATH) != OK:
		return entries
	var config_section := STORAGE_PARTY_SECTION if section == &"party" else STORAGE_BAG_SECTION
	for slot_index in slot_count:
		var texture_path := String(config.get_value(config_section, STORAGE_ITEM_TEXTURE_KEY_FORMAT % slot_index, ""))
		if texture_path.is_empty():
			continue
		entries.append({
			"slot_index": slot_index,
			"texture_path": texture_path,
			"quality": StringName(config.get_value(config_section, STORAGE_ITEM_QUALITY_KEY_FORMAT % slot_index, default_quality)),
		})
	return entries


func save_storage(
	party_items: Array,
	party_qualities: Array[StringName],
	bag_items: Array,
	bag_qualities: Array[StringName],
	default_quality: StringName
) -> Error:
	var config := ConfigFile.new()
	_write_storage_section(config, STORAGE_PARTY_SECTION, party_items, party_qualities, default_quality)
	_write_storage_section(config, STORAGE_BAG_SECTION, bag_items, bag_qualities, default_quality)
	return config.save(STORAGE_STATE_PATH)


func reset_storage() -> Error:
	var config := ConfigFile.new()
	config.set_value("storage", "initialized", true)
	return config.save(STORAGE_STATE_PATH)


func _write_storage_section(
	config: ConfigFile,
	section: String,
	items: Array,
	qualities: Array[StringName],
	default_quality: StringName
) -> void:
	for slot_index in items.size():
		var item_texture := items[slot_index] as Texture2D
		if item_texture == null or item_texture.resource_path.is_empty():
			continue
		var quality := qualities[slot_index] if slot_index < qualities.size() else default_quality
		config.set_value(section, STORAGE_ITEM_TEXTURE_KEY_FORMAT % slot_index, item_texture.resource_path)
		config.set_value(section, STORAGE_ITEM_QUALITY_KEY_FORMAT % slot_index, quality)

