extends NinePatchRect

const DATA_PROVIDER_SCRIPT := preload("res://Data/GameDataProvider.gd")
const SESSION_STORE_SCRIPT := preload("res://Data/GameSessionStore.gd")
const CLOCK_INDICATOR_SCENE := preload("res://FloatingUI/Prefabs/ClockIndicator.tscn")
const PET_UNIT_SCENE := preload("res://Battle/Prefabs/Pet/BattleUnit.tscn")

const ANIM_SHOW_THREE_OPTION := &"show_Three_Option"
const ANIM_HIDE_THREE_OPTION := &"hide_Three_Option"
const ANIM_SHOW_SHOP := &"show_Shop"
const ANIM_HIDE_SHOP := &"hide_Shop"
const ANIM_SHOW_BAG := &"show_Bag"
const ANIM_HIDE_BAG := &"hide_bag"

const VIEW_THREE_OPTION := &"three_option"
const VIEW_SHOP := &"shop"
const VIEW_BAG := &"bag"

const OPTION_SHOP := &"shop"
const OPTION_EVENT := &"event"
const OPTION_BATTLE := &"battle"
const SPRITE_INFO_DATABASE_PATH := "res://FloatingUI/Resources/SpriteInfo/SpriteInfoDatabase.tres"
const SPRITE_INFO_PANEL_SCRIPT_PATH := "res://FloatingUI/Prefabs/SpriteInfoPanel.gd"
const SHOP_INFO_PANEL_LEFT_EDGE := 1548.0
const SHOP_INFO_PANEL_RIGHT_MARGIN := 24.0
const SHOP_INFO_PANEL_VERTICAL_MARGIN := 64.0
const SHOP_INFO_PANEL_ASPECT_HEIGHT_RATIO := 1.526
const THREE_OPTION_SHOP_LOGO_PATH := "res://FloatingUI/images/Three_Shop_Logo.png"
const THREE_OPTION_EVENT_LOGO_PATH := "res://FloatingUI/images/Three_Qi_Logo.png"
const THREE_OPTION_BATTLE_LOGO_PATH := "res://FloatingUI/images/Three_Fight_Logo.png"
const THREE_OPTION_LOGO_SIZE := Vector2(64.0, 83.0)
const THREE_OPTION_LOGO_EDGE_OVERLAP := 28.0
const BATTLE_SCENE_PATH := "res://Battle/Scenes/battle_main_scene.tscn"
const RETURN_FROM_BATTLE_META := &"returning_from_battle"
const SHOP_GOLD_CHEAT_REWARD := 100
const SHOP_GOLD_CHEAT_SEQUENCE := [
	KEY_UP,
	KEY_UP,
	KEY_DOWN,
	KEY_DOWN,
	KEY_LEFT,
	KEY_RIGHT,
	KEY_LEFT,
	KEY_RIGHT,
	KEY_B,
	KEY_A,
]
const DRAG_START_DISTANCE := 12.0
# Fill each 230 x 220 party/shop cell with the creature. The ready-to-use bronze
# frame has transparent padding, so its render bounds remain larger than the cell
# while its visible border lines up with the cell edges.
const CREATURE_SLOT_SIZE := Vector2(220.0, 220.0)
const CREATURE_FRAME_RENDER_SIZE := Vector2(260.0, 260.0)
const CREATURE_SILVER_FRAME_RENDER_SIZE := Vector2(238.0, 238.0)
const CREATURE_QUALITY_BRONZE := &"bronze"
const CREATURE_QUALITY_SILVER := &"silver"
const CREATURE_QUALITY_GOLD := &"gold"
const CREATURE_QUALITY_DIAMOND := &"diamond"
const BRONZE_FRAME_TEXTURE_PATH := "res://FloatingUI/output/topper-ready-frames/bronze-frame-top-clear-220.png"
const CREATURE_FRAME_TEXTURE_PATHS := {
	CREATURE_QUALITY_BRONZE: BRONZE_FRAME_TEXTURE_PATH,
	CREATURE_QUALITY_SILVER: "res://FloatingUI/output/topper-ready-frames/silver-frame-top-clear-220.png",
	CREATURE_QUALITY_GOLD: "res://FloatingUI/output/topper-ready-frames/royal-frame-top-clear-220.png",
	CREATURE_QUALITY_DIAMOND: "res://FloatingUI/output/topper-ready-frames/diamond-frame-top-clear-220.png",
}
const CREATURE_TOPPER_TEXTURE_PATH := "res://FloatingUI/assets/ruby-topper/ruby-topper-1.png"
const CREATURE_BACKGROUND_TEXTURE_DIR := "res://FloatingUI/images/card_backgrounds"
const CREATURE_BACKGROUND_NODE_NAME := &"CreatureBackground"
const CREATURE_FRAME_NODE_NAME := &"CreatureFrame"
const CREATURE_TOPPER_NODE_NAME := &"CreatureTopper"
const SHARED_PET_VIEW_NODE_NAME := &"SharedPetView"
const SHARED_PET_VIEW_META := &"uses_shared_pet_prefab"
const CREATURE_TOPPER_CENTER := Vector2(110.0, 10.0)
const MERGE_INDICATOR_TEXTURE_PATH := "res://FloatingUI/images/Indicators/sprite_merge_upgrade_chevrons_220.png"
const MERGE_INDICATOR_CLIP_NODE_NAME := &"MergeIndicatorClip"
const MERGE_INDICATOR_NODE_NAME := &"MergeUpgradeIndicator"
const MERGE_INDICATOR_FOLLOWER_NODE_NAME := &"MergeUpgradeIndicatorFollower"
# One full card-height cycle lets an identical second texture enter from below
# while the first exits above. When the tween wraps, both images occupy exactly
# the same pixels as before, so the infinite loop has no visible jump.
const MERGE_INDICATOR_TRAVEL_PX := CREATURE_SLOT_SIZE.y
const MERGE_INDICATOR_LOOP_DURATION := 1.15
const MERGE_ANIMATION_BURST_TEXTURE_PATH := "res://FloatingUI/images/Effects/merge_upgrade_burst.png"
const MERGE_ANIMATION_ROOT_NAME := &"MergeAnimationOverlay"
const MERGE_ANIMATION_SOURCE_NAME := &"MergeSourceCard"
const MERGE_ANIMATION_TARGET_NAME := &"MergeTargetCard"
const MERGE_ANIMATION_BURST_NAME := &"MergeBurst"
const TARGET_AUTO := &"auto"
const TARGET_PARTY := &"party"
const TARGET_BAG := &"bag"
const DRAG_SOURCE_NONE := &"none"
const DRAG_SOURCE_SHOP := &"shop"
const DRAG_SOURCE_PARTY := &"party"
const DRAG_SOURCE_BAG := &"bag"
const CLOCK_POSITION := Vector2(22.0, 519.0)
const CLOCK_SIZE := 155.0
const CLOCK_HOURS_PER_DAY := 6
const BAG_BUTTON_POSITION := Vector2(0.0, 52.0)
const BAG_BUTTON_SIZE := Vector2(220.0, 168.0)

# Keep the upgrade prompt clearly visible over both light and dark creature art.
# It can still be tuned in the Inspector or through
# set_merge_indicator_opacity().
@export_range(0.05, 1.0, 0.01) var merge_indicator_opacity := 0.72
@export_range(0.4, 1.5, 0.05) var merge_animation_duration := 0.8

@onready var animation_player: AnimationPlayer = $"../../../AnimationPlayer"
@onready var middle_three_option: GridContainer = $Middle_Three_Option
@onready var middle_shop: GridContainer = $Middle_Shop
@onready var middle_bag: GridContainer = $Middle_Bag
@onready var party_container: GridContainer = $"../Party/Party_Container"
@onready var top_shop: GridContainer = $"../Top/Top_Shop"
@onready var top_sell_button: Button = $"../Top/Top_Sell"
@onready var shop_back_button: TextureButton = $"../Top/Top_Shop/Shop_BackButton"
@onready var bag_button: TextureButton = $"../Bags/Bag_Button"
@onready var gold_label: Label = $"../../GoldCounter/GoldLabel"

var _is_transitioning := false
var _current_view := VIEW_THREE_OPTION
var _view_before_bag := VIEW_THREE_OPTION
var _random := RandomNumberGenerator.new()
var _shop_item_textures: Array[Texture2D] = []
var _sprite_info_database: SpriteInfoDatabase = null
var _shop_buttons: Array[TextureButton] = []
var _shop_slots: Array[Control] = []
var _shop_items: Array = []
var _shop_item_qualities: Array[StringName] = []
var _party_buttons: Array[TextureButton] = []
var _party_slots: Array[Control] = []
var _party_items: Array = []
var _party_item_qualities: Array[StringName] = []
var _bag_buttons: Array[TextureButton] = []
var _bag_slots: Array[Control] = []
var _bag_items: Array = []
var _bag_item_qualities: Array[StringName] = []
var _bag_capacity_beans: Array[TextureRect] = []
var _drag_candidate_source := DRAG_SOURCE_NONE
var _drag_candidate_index := -1
var _drag_candidate_start := Vector2.ZERO
var _is_dragging_shop_item := false
var _is_dragging_storage_item := false
var _drag_preview: Control = null
var _creature_frame_textures: Dictionary = {}
var _creature_topper_texture: Texture2D = null
var _creature_background_textures: Dictionary = {}
var _merge_indicator_texture: Texture2D = null
var _merge_animation_burst_texture: Texture2D = null
var _merge_animation_queue: Array[Dictionary] = []
var _merge_hidden_controls: Dictionary = {}
var _merge_animation_is_playing := false
var _merge_animations_enabled := false
var _three_option_buttons: Array[TextureButton] = []
var _three_option_logos: Array[TextureRect] = []
var _three_option_kinds: Array[StringName] = []
var _clock_root: Node2D = null
var _clock_total_hours := 0
var _clock_hour := 0
var _clock_day := 1
var _gold := 0
var _shop_gold_cheat_index := 0
var _shop_info_panel: Control = null
var _hovered_info_source := DRAG_SOURCE_NONE
var _hovered_info_index := -1
var _data_provider = DATA_PROVIDER_SCRIPT.new()
var _session_store = SESSION_STORE_SCRIPT.new()
var _shop_data: Dictionary = {}
var _quality_order: Array[StringName] = []


func _ready() -> void:
	_load_project_data()
	_random.randomize()
	var is_returning_from_battle := _is_returning_from_battle()
	if is_returning_from_battle:
		_load_gold_state()
		_load_clock_state()
	else:
		_reset_gold_state()
		_reset_clock_state()
	_update_gold_display()
	_prepare_clock_indicator()
	_shop_item_textures = _load_textures_from_folder(_shop_path("creature_catalog_dir", "res://FloatingUI/SpriteImages"))
	_load_sprite_info_database()
	_create_shop_info_panel()
	_prepare_three_option_buttons()
	_prepare_buttons()
	_prepare_sell_button()
	_prepare_shop_buttons()
	_prepare_storage_slots()
	if is_returning_from_battle:
		_load_storage_state()
	else:
		_reset_storage_state()
	_prepare_bag_capacity_bar()
	_show_initial_three_option()
	_merge_animations_enabled = true


func _load_project_data() -> void:
	_shop_data = _data_provider.get_shop_data()
	_quality_order.clear()
	for quality in _shop_data.get("quality_order", []):
		_quality_order.append(StringName(quality))


func _shop_int(key: String, fallback: int) -> int:
	return int(_shop_data.get(key, fallback))


func _shop_path(key: String, fallback := "") -> String:
	return String(_shop_data.get(key, fallback))


func _load_gold_state() -> void:
	_gold = _session_store.load_gold(_shop_int("initial_gold", 15))


func _reset_gold_state() -> void:
	_gold = _shop_int("initial_gold", 15)
	_save_gold_state()


func _save_gold_state() -> void:
	var error: Error = _session_store.save_gold(_gold)
	if error != OK:
		push_warning("Failed to save gold state.")


func _load_storage_state() -> void:
	_restore_storage_items(
		_session_store.load_storage(DRAG_SOURCE_PARTY, _party_items.size(), CREATURE_QUALITY_BRONZE),
		DRAG_SOURCE_PARTY
	)
	_restore_storage_items(
		_session_store.load_storage(DRAG_SOURCE_BAG, _bag_items.size(), CREATURE_QUALITY_BRONZE),
		DRAG_SOURCE_BAG
	)
	# Older saves can contain pairs created before cascading upgrades were
	# supported. Reconcile them once everything has been restored.
	if _merge_all_storage_items():
		_save_storage_state()
	_refresh_bag_capacity_bar()


func _restore_storage_items(entries: Array[Dictionary], source: StringName) -> void:
	for entry in entries:
		var slot_index := int(entry.get("slot_index", -1))
		var texture_path := String(entry.get("texture_path", ""))
		var item_texture := load(texture_path) as Texture2D
		if item_texture == null:
			push_warning("Failed to restore card texture: %s" % texture_path)
			continue
		var quality := _normalize_creature_quality(StringName(entry.get("quality", CREATURE_QUALITY_BRONZE)))
		_set_storage_item(source, slot_index, item_texture, quality)


func _save_storage_state() -> void:
	var error: Error = _session_store.save_storage(
		_party_items,
		_party_item_qualities,
		_bag_items,
		_bag_item_qualities,
		CREATURE_QUALITY_BRONZE
	)
	if error != OK:
		push_warning("Failed to save card storage state.")


func _reset_storage_state() -> void:
	var error: Error = _session_store.reset_storage()
	if error != OK:
		push_warning("Failed to reset card storage state.")


func _normalize_creature_quality(quality: StringName) -> StringName:
	return quality if _quality_order.has(quality) else CREATURE_QUALITY_BRONZE


func _load_clock_state() -> void:
	_set_clock_total_hours(_session_store.load_clock_total_hours(0))


func _reset_clock_state() -> void:
	_set_clock_total_hours(0)
	_save_clock_state()


func _is_returning_from_battle() -> bool:
	if not get_tree().has_meta(RETURN_FROM_BATTLE_META):
		return false

	var is_returning := bool(get_tree().get_meta(RETURN_FROM_BATTLE_META))
	get_tree().remove_meta(RETURN_FROM_BATTLE_META)
	return is_returning


func _save_clock_state() -> void:
	var error: Error = _session_store.save_clock(_clock_total_hours, _clock_hour, _clock_day)
	if error != OK:
		push_warning("Failed to save clock state.")


func save_session_state() -> void:
	_save_gold_state()
	_save_clock_state()
	_save_storage_state()


func _change_gold(delta: int) -> void:
	_gold = max(0, _gold + delta)
	_save_gold_state()
	_update_gold_display()
	_refresh_shop_affordability()


func _update_gold_display() -> void:
	if gold_label != null:
		gold_label.text = str(_gold)


func _refresh_shop_affordability() -> void:
	for index in _shop_buttons.size():
		if index >= _shop_items.size() or index >= _shop_slots.size():
			continue

		var button := _shop_buttons[index]
		var has_item := _shop_items[index] != null and _shop_slots[index].visible
		button.disabled = has_item and _gold < _shop_int("buy_price", 2)
		button.modulate = Color(1.0, 1.0, 1.0, 1.0) if not button.disabled else Color(0.65, 0.65, 0.65, 0.72)


func _prepare_three_option_buttons() -> void:
	var boss_image_dir := _shop_path("shop_boss_image_dir", "res://FloatingUI/ShopBossImages")
	var boss_textures := _load_textures_from_folder(boss_image_dir)
	_three_option_buttons = _get_texture_buttons(middle_three_option)
	_three_option_logos.clear()
	_three_option_kinds.clear()

	if boss_textures.size() < _three_option_buttons.size():
		push_warning("Not enough boss images in %s" % boss_image_dir)

	for index in _three_option_buttons.size():
		var button := _three_option_buttons[index]
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED

		if index < boss_textures.size():
			button.texture_normal = boss_textures[index]

		var pressed_callable := _on_three_option_button_pressed.bind(index)
		if not button.pressed.is_connected(pressed_callable):
			button.pressed.connect(pressed_callable)

		_three_option_logos.append(_create_three_option_logo(index))
		_three_option_kinds.append(OPTION_SHOP)

	_refresh_three_options()


func _create_three_option_logo(index: int) -> TextureRect:
	var main_bg := get_node_or_null("../..") as Control
	var logo := TextureRect.new()
	logo.name = "ThreeOptionLogo%d" % (index + 1)
	logo.size = THREE_OPTION_LOGO_SIZE
	logo.custom_minimum_size = THREE_OPTION_LOGO_SIZE
	logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	logo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	logo.z_index = 100
	logo.visible = false

	if main_bg != null:
		main_bg.add_child.call_deferred(logo)
	else:
		add_child.call_deferred(logo)

	return logo


func _refresh_three_options() -> void:
	var option_kinds := _build_three_option_kinds_for_hour(_clock_hour)

	for index in _three_option_buttons.size():
		if index >= option_kinds.size():
			continue

		var kind: StringName = option_kinds[index]
		_three_option_kinds[index] = kind

		if index < _three_option_logos.size():
			_three_option_logos[index].texture = _load_three_option_logo(kind)

	_update_three_option_logo_positions()


func _build_three_option_kinds_for_hour(hour: int) -> Array[StringName]:
	match hour:
		2, 5:
			return [OPTION_BATTLE, OPTION_BATTLE, OPTION_BATTLE]
		1, 3:
			return [OPTION_EVENT, OPTION_SHOP, OPTION_EVENT]
		4:
			return [OPTION_SHOP, OPTION_EVENT, OPTION_SHOP]
		_:
			return [OPTION_SHOP, OPTION_EVENT, OPTION_SHOP]


func _load_three_option_logo(kind: StringName) -> Texture2D:
	match kind:
		OPTION_BATTLE:
			return load(THREE_OPTION_BATTLE_LOGO_PATH) as Texture2D
		OPTION_EVENT:
			return load(THREE_OPTION_EVENT_LOGO_PATH) as Texture2D
		_:
			return load(THREE_OPTION_SHOP_LOGO_PATH) as Texture2D


func _process(_delta: float) -> void:
	_update_three_option_logo_positions()


func _update_three_option_logo_positions() -> void:
	for index in _three_option_logos.size():
		var logo := _three_option_logos[index]
		var has_button := index < _three_option_buttons.size() and _three_option_buttons[index] != null
		logo.visible = has_button and middle_three_option.visible

		if not logo.visible:
			continue

		var button := _three_option_buttons[index]
		var button_rect := button.get_global_rect()
		logo.global_position = Vector2(
			button_rect.get_center().x - logo.size.x * 0.5,
			button_rect.end.y - THREE_OPTION_LOGO_EDGE_OVERLAP
		)


func _prepare_buttons() -> void:
	_configure_bag_button()
	shop_back_button.pressed.connect(_on_shop_back_button_pressed)
	bag_button.pressed.connect(_on_bag_button_pressed)


func _configure_bag_button() -> void:
	bag_button.position = BAG_BUTTON_POSITION
	bag_button.size = BAG_BUTTON_SIZE
	bag_button.custom_minimum_size = BAG_BUTTON_SIZE
	bag_button.ignore_texture_size = true
	bag_button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	bag_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND


func _prepare_shop_buttons() -> void:
	_shop_buttons = _get_texture_buttons(middle_shop)
	_shop_slots.clear()
	_shop_items.clear()
	_shop_item_qualities.clear()

	for index in _shop_buttons.size():
		var button := _shop_buttons[index]
		_shop_slots.append(button.get_parent() as Control)
		_shop_items.append(null)
		_shop_item_qualities.append(CREATURE_QUALITY_BRONZE)
		_configure_creature_button(button)

		if not button.button_down.is_connected(_on_shop_button_down):
			button.button_down.connect(_on_shop_button_down.bind(index))
		if not button.mouse_entered.is_connected(_on_shop_button_mouse_entered):
			button.mouse_entered.connect(_on_shop_button_mouse_entered.bind(index))
		if not button.mouse_exited.is_connected(_on_shop_button_mouse_exited):
			button.mouse_exited.connect(_on_shop_button_mouse_exited.bind(index))


func _prepare_storage_slots() -> void:
	_party_slots = _get_direct_control_children(party_container)
	_party_buttons = _get_texture_buttons(party_container)
	_party_items.clear()
	_party_item_qualities.clear()

	for index in _party_buttons.size():
		_party_items.append(null)
		_party_item_qualities.append(CREATURE_QUALITY_BRONZE)
		_configure_inventory_button(_party_buttons[index])
		if not _party_buttons[index].button_down.is_connected(_on_party_button_down):
			_party_buttons[index].button_down.connect(_on_party_button_down.bind(index))
		if not _party_buttons[index].mouse_entered.is_connected(_on_party_button_mouse_entered):
			_party_buttons[index].mouse_entered.connect(_on_party_button_mouse_entered.bind(index))
		if not _party_buttons[index].mouse_exited.is_connected(_on_party_button_mouse_exited):
			_party_buttons[index].mouse_exited.connect(_on_party_button_mouse_exited.bind(index))

	_bag_slots = _get_direct_control_children(middle_bag)
	_bag_buttons = _get_texture_buttons(middle_bag)
	_bag_items.clear()
	_bag_item_qualities.clear()

	for index in _bag_buttons.size():
		_bag_items.append(null)
		_bag_item_qualities.append(CREATURE_QUALITY_BRONZE)
		_configure_inventory_button(_bag_buttons[index])
		if not _bag_buttons[index].button_down.is_connected(_on_bag_slot_button_down):
			_bag_buttons[index].button_down.connect(_on_bag_slot_button_down.bind(index))
		if not _bag_buttons[index].mouse_entered.is_connected(_on_bag_button_mouse_entered):
			_bag_buttons[index].mouse_entered.connect(_on_bag_button_mouse_entered.bind(index))
		if not _bag_buttons[index].mouse_exited.is_connected(_on_bag_button_mouse_exited):
			_bag_buttons[index].mouse_exited.connect(_on_bag_button_mouse_exited.bind(index))


func _prepare_bag_capacity_bar() -> void:
	_bag_capacity_beans.clear()
	var ability_bar := get_node_or_null("../Bags/AbilityBar")
	if ability_bar == null:
		return

	for child in ability_bar.get_children():
		if child is TextureRect and child.name.begins_with("Bean"):
			var bean := child as TextureRect
			bean.mouse_filter = Control.MOUSE_FILTER_IGNORE
			_bag_capacity_beans.append(bean)

	_refresh_bag_capacity_bar()


func _refresh_bag_capacity_bar() -> void:
	if _bag_capacity_beans.is_empty():
		return

	var filled_count := 0
	for item in _bag_items:
		if item != null:
			filled_count += 1

	for index in _bag_capacity_beans.size():
		_bag_capacity_beans[index].visible = index < filled_count


func _configure_inventory_button(button: TextureButton) -> void:
	button.texture_normal = null
	button.texture_hover = null
	button.texture_pressed = null
	button.texture_disabled = null
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	button.ignore_texture_size = true
	button.custom_minimum_size = CREATURE_SLOT_SIZE
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	button.set_meta(SHARED_PET_VIEW_META, true)
	_ensure_shared_pet_view(button).call("clear_collection_data")


func _ensure_shared_pet_view(button: TextureButton) -> Control:
	var pet_view := button.get_node_or_null(NodePath(SHARED_PET_VIEW_NODE_NAME)) as Control
	if pet_view != null:
		return pet_view
	pet_view = PET_UNIT_SCENE.instantiate() as Control
	pet_view.name = SHARED_PET_VIEW_NODE_NAME
	pet_view.position = Vector2.ZERO
	pet_view.size = CREATURE_SLOT_SIZE
	pet_view.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(pet_view)
	return pet_view


func _configure_creature_button(button: TextureButton) -> void:
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	button.ignore_texture_size = true
	button.custom_minimum_size = CREATURE_SLOT_SIZE
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	_ensure_creature_background(button)
	_ensure_creature_frame(button)
	_ensure_creature_topper(button)


func _ensure_creature_background(button: TextureButton) -> void:
	var background := button.get_node_or_null(NodePath(CREATURE_BACKGROUND_NODE_NAME)) as TextureRect
	if background == null:
		background = TextureRect.new()
		background.name = CREATURE_BACKGROUND_NODE_NAME
		background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		background.stretch_mode = TextureRect.STRETCH_SCALE
		background.mouse_filter = Control.MOUSE_FILTER_IGNORE
		background.show_behind_parent = true
		button.add_child(background)

	background.visible = button.texture_normal != null


func _ensure_creature_frame(button: TextureButton) -> void:
	var frame := button.get_node_or_null(NodePath(CREATURE_FRAME_NODE_NAME)) as TextureRect
	if frame == null:
		frame = TextureRect.new()
		frame.name = CREATURE_FRAME_NODE_NAME
		frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		frame.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
		frame.z_index = 1
		button.add_child(frame)

	frame.texture = _get_creature_frame_texture(CREATURE_QUALITY_BRONZE)
	_layout_creature_frame(frame, CREATURE_QUALITY_BRONZE)
	frame.visible = button.texture_normal != null


func _ensure_creature_topper(button: TextureButton) -> void:
	var topper := button.get_node_or_null(NodePath(CREATURE_TOPPER_NODE_NAME)) as Sprite2D
	if topper == null:
		topper = Sprite2D.new()
		topper.name = CREATURE_TOPPER_NODE_NAME
		topper.centered = true
		topper.z_index = 2
		button.add_child(topper)

	# The gem is scaled with the frame, centered horizontally, and placed in the
	# vertical middle of the card's top border rather than above it.
	topper.position = CREATURE_TOPPER_CENTER
	topper.scale = Vector2.ONE * (CREATURE_FRAME_RENDER_SIZE.x / CREATURE_SLOT_SIZE.x)
	topper.texture = _get_creature_topper_texture()
	topper.visible = button.texture_normal != null


func _ensure_merge_indicator(button: TextureButton) -> TextureRect:
	var clip := button.get_node_or_null(NodePath(MERGE_INDICATOR_CLIP_NODE_NAME)) as Control
	if clip == null:
		clip = Control.new()
		clip.name = MERGE_INDICATOR_CLIP_NODE_NAME
		clip.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		clip.mouse_filter = Control.MOUSE_FILTER_IGNORE
		clip.clip_contents = true
		clip.z_index = 3
		button.add_child(clip)

	var indicator := clip.get_node_or_null(NodePath(MERGE_INDICATOR_NODE_NAME)) as TextureRect
	if indicator == null:
		indicator = TextureRect.new()
		indicator.name = MERGE_INDICATOR_NODE_NAME
		indicator.size = CREATURE_SLOT_SIZE
		indicator.texture = _get_merge_indicator_texture()
		indicator.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		indicator.stretch_mode = TextureRect.STRETCH_SCALE
		indicator.mouse_filter = Control.MOUSE_FILTER_IGNORE
		clip.add_child(indicator)

	var follower := indicator.get_node_or_null(
		NodePath(MERGE_INDICATOR_FOLLOWER_NODE_NAME)
	) as TextureRect
	if follower == null:
		follower = TextureRect.new()
		follower.name = MERGE_INDICATOR_FOLLOWER_NODE_NAME
		follower.position = Vector2(0.0, MERGE_INDICATOR_TRAVEL_PX)
		follower.size = CREATURE_SLOT_SIZE
		follower.texture = _get_merge_indicator_texture()
		follower.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		follower.stretch_mode = TextureRect.STRETCH_SCALE
		follower.mouse_filter = Control.MOUSE_FILTER_IGNORE
		indicator.add_child(follower)

	if not indicator.has_meta("merge_animation_started"):
		indicator.set_meta("merge_animation_started", true)
		_start_merge_indicator_animation(indicator)

	indicator.modulate = Color(1.0, 1.0, 1.0, merge_indicator_opacity)
	return indicator


func _start_merge_indicator_animation(indicator: TextureRect) -> void:
	indicator.position = Vector2.ZERO
	var tween := indicator.create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(
		indicator,
		"position:y",
		-MERGE_INDICATOR_TRAVEL_PX,
		MERGE_INDICATOR_LOOP_DURATION
	).from(0.0)
	# Explicitly restoring the start value matters for a property tweener: without
	# it, later iterations start at the previous target and appear stationary.
	tween.set_loops()


func _get_merge_indicator_texture() -> Texture2D:
	if _merge_indicator_texture == null:
		_merge_indicator_texture = load(MERGE_INDICATOR_TEXTURE_PATH) as Texture2D
		if _merge_indicator_texture == null:
			push_warning("Merge indicator is missing: %s" % MERGE_INDICATOR_TEXTURE_PATH)

	return _merge_indicator_texture


func set_merge_indicator_opacity(opacity: float) -> void:
	merge_indicator_opacity = clampf(opacity, 0.05, 1.0)
	_refresh_merge_indicators()


func _refresh_merge_indicators() -> void:
	# Owned duplicates merge immediately, so only shop cards paired with a
	# matching owned card need a persistent upgrade prompt.
	var shop_item_counts: Dictionary = {}
	var storage_item_counts: Dictionary = {}
	_count_mergeable_creatures(_shop_items, _shop_item_qualities, shop_item_counts)
	_count_mergeable_creatures(_party_items, _party_item_qualities, storage_item_counts)
	_count_mergeable_creatures(_bag_items, _bag_item_qualities, storage_item_counts)

	_refresh_merge_indicators_for_cards(
		_shop_buttons, _shop_items, _shop_item_qualities, storage_item_counts
	)
	_refresh_merge_indicators_for_cards(
		_party_buttons, _party_items, _party_item_qualities, shop_item_counts
	)
	_refresh_merge_indicators_for_cards(
		_bag_buttons, _bag_items, _bag_item_qualities, shop_item_counts
	)


func _count_mergeable_creatures(
	items: Array,
	qualities: Array[StringName],
	item_counts: Dictionary
) -> void:
	for index in items.size():
		var item: Variant = items[index]
		var item_texture: Texture2D = item as Texture2D
		if item_texture == null:
			continue

		var creature_key := _get_merge_creature_key(item_texture, _get_quality_at(qualities, index))
		item_counts[creature_key] = int(item_counts.get(creature_key, 0)) + 1


func _refresh_merge_indicators_for_cards(
	buttons: Array[TextureButton],
	items: Array,
	qualities: Array[StringName],
	matching_item_counts: Dictionary
) -> void:
	var count: int = min(buttons.size(), items.size())
	for index in count:
		var item_texture: Texture2D = items[index] as Texture2D
		var indicator: TextureRect = _ensure_merge_indicator(buttons[index])
		var quality := _get_quality_at(qualities, index)
		var is_mergeable: bool = item_texture != null \
			and _get_next_creature_quality(quality) != StringName() \
			and int(matching_item_counts.get(
				_get_merge_creature_key(item_texture, quality), 0
			)) > 0
		indicator.visible = is_mergeable


func _get_quality_at(qualities: Array[StringName], index: int) -> StringName:
	if index >= 0 and index < qualities.size():
		return qualities[index]

	return CREATURE_QUALITY_BRONZE


func _get_merge_creature_key(item_texture: Texture2D, quality: StringName) -> String:
	return "%s|%s" % [item_texture.resource_path, quality]


func _get_creature_frame_texture(quality: StringName) -> Texture2D:
	if not _creature_frame_textures.has(quality):
		var texture_path := str(CREATURE_FRAME_TEXTURE_PATHS.get(quality, BRONZE_FRAME_TEXTURE_PATH))
		_creature_frame_textures[quality] = load(texture_path) as Texture2D
		if _creature_frame_textures[quality] == null:
			push_warning("Creature frame is missing: %s" % texture_path)

	return _creature_frame_textures[quality] as Texture2D


func _get_creature_frame_render_size(quality: StringName) -> Vector2:
	# The silver source art has substantially less transparent padding than the
	# other frame textures. Render it in a smaller box so its visible outer edge
	# aligns with the same 220 px card bounds instead of appearing oversized.
	if _normalize_creature_quality(quality) == CREATURE_QUALITY_SILVER:
		return CREATURE_SILVER_FRAME_RENDER_SIZE

	return CREATURE_FRAME_RENDER_SIZE


func _layout_creature_frame(frame: TextureRect, quality: StringName) -> void:
	var render_size := _get_creature_frame_render_size(quality)
	frame.position = (CREATURE_SLOT_SIZE - render_size) * 0.5
	frame.size = render_size


func _get_creature_topper_texture() -> Texture2D:
	if _creature_topper_texture == null:
		_creature_topper_texture = load(CREATURE_TOPPER_TEXTURE_PATH) as Texture2D
		if _creature_topper_texture == null:
			push_warning("Creature topper is missing: %s" % CREATURE_TOPPER_TEXTURE_PATH)

	return _creature_topper_texture


func _queue_merge_animation(
	source_button: Control,
	target_button: Control,
	item_texture: Texture2D,
	from_quality: StringName,
	to_quality: StringName
) -> void:
	if not _merge_animations_enabled or item_texture == null or to_quality == StringName():
		return
	if not is_instance_valid(target_button) or not target_button.is_visible_in_tree():
		return

	var target_center := target_button.get_global_rect().get_center()
	var visible_source: Control = source_button
	if not is_instance_valid(visible_source) or not visible_source.is_visible_in_tree():
		visible_source = null

	var source_center := target_center + Vector2(CREATURE_SLOT_SIZE.x * 0.85, 0.0)
	if visible_source != null:
		source_center = visible_source.get_global_rect().get_center()

	_hold_control_for_merge(visible_source)
	if target_button != visible_source:
		_hold_control_for_merge(target_button)

	_merge_animation_queue.append({
		"source_button": visible_source,
		"target_button": target_button,
		"source_center": source_center,
		"target_center": target_center,
		"item_texture": item_texture,
		"from_quality": from_quality,
		"to_quality": to_quality,
	})
	if not _merge_animation_is_playing:
		_play_next_merge_animation.call_deferred()


func _retarget_queued_merge_animation(old_button: Control, new_button: Control) -> void:
	if not is_instance_valid(old_button) or not is_instance_valid(new_button):
		return
	if not new_button.is_visible_in_tree():
		return

	for queue_index in range(_merge_animation_queue.size() - 1, -1, -1):
		var merge_event: Dictionary = _merge_animation_queue[queue_index]
		if merge_event.get("target_button") != old_button:
			continue

		_release_control_after_merge(old_button)
		_hold_control_for_merge(new_button)
		merge_event["target_button"] = new_button
		merge_event["target_center"] = new_button.get_global_rect().get_center()
		_merge_animation_queue[queue_index] = merge_event
		return


func _play_next_merge_animation() -> void:
	if _merge_animation_is_playing or _merge_animation_queue.is_empty():
		return

	_merge_animation_is_playing = true
	var merge_event: Dictionary = _merge_animation_queue.pop_front()
	await _play_merge_animation(merge_event)
	var source_button := merge_event.get("source_button") as Control
	_release_control_after_merge(source_button)
	var target_button := merge_event.get("target_button") as Control
	if target_button != source_button:
		_release_control_after_merge(target_button)
	_merge_animation_is_playing = false
	if not _merge_animation_queue.is_empty():
		_play_next_merge_animation()


func _play_merge_animation(merge_event: Dictionary) -> void:
	var scene := get_tree().current_scene
	if scene == null:
		return

	var item_texture := merge_event.get("item_texture") as Texture2D
	var from_quality := StringName(merge_event.get("from_quality", CREATURE_QUALITY_BRONZE))
	var to_quality := StringName(merge_event.get("to_quality", CREATURE_QUALITY_SILVER))
	var source_center := merge_event.get("source_center", Vector2.ZERO) as Vector2
	var target_center := merge_event.get("target_center", Vector2.ZERO) as Vector2
	var merge_center := (source_center + target_center) * 0.5

	var overlay := Control.new()
	overlay.name = MERGE_ANIMATION_ROOT_NAME
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.z_index = 1000
	scene.add_child(overlay)

	var source_card := _create_merge_animation_card(item_texture, from_quality)
	source_card.name = MERGE_ANIMATION_SOURCE_NAME
	var target_card := _create_merge_animation_card(item_texture, from_quality)
	target_card.name = MERGE_ANIMATION_TARGET_NAME
	overlay.add_child(source_card)
	overlay.add_child(target_card)
	source_card.global_position = source_center - CREATURE_SLOT_SIZE * 0.5
	target_card.global_position = target_center - CREATURE_SLOT_SIZE * 0.5
	source_card.rotation = deg_to_rad(2.0)
	target_card.rotation = deg_to_rad(-2.0)

	var burst := TextureRect.new()
	burst.name = MERGE_ANIMATION_BURST_NAME
	burst.texture = _get_merge_animation_burst_texture()
	burst.size = Vector2(360.0, 360.0)
	burst.pivot_offset = burst.size * 0.5
	burst.global_position = merge_center - burst.size * 0.5
	burst.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	burst.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	burst.mouse_filter = Control.MOUSE_FILTER_IGNORE
	burst.modulate = Color(1.0, 1.0, 1.0, 0.0)
	burst.scale = Vector2.ONE * 0.18
	overlay.add_child(burst)
	burst.move_to_front()

	var approach_duration := merge_animation_duration * 0.375
	var impact_duration := merge_animation_duration * 0.225
	var settle_duration := merge_animation_duration * 0.275
	var reveal_duration := merge_animation_duration * 0.125

	var approach := overlay.create_tween().set_parallel(true)
	approach.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	approach.tween_property(
		source_card, "global_position", merge_center - CREATURE_SLOT_SIZE * 0.5 + Vector2(-12.0, 0.0),
		approach_duration
	)
	approach.tween_property(
		target_card, "global_position", merge_center - CREATURE_SLOT_SIZE * 0.5 + Vector2(12.0, 0.0),
		approach_duration
	)
	approach.tween_property(source_card, "rotation", deg_to_rad(-7.0), approach_duration)
	approach.tween_property(target_card, "rotation", deg_to_rad(7.0), approach_duration)
	approach.tween_property(source_card, "scale", Vector2.ONE * 1.06, approach_duration)
	approach.tween_property(target_card, "scale", Vector2.ONE * 1.06, approach_duration)
	await approach.finished

	if not is_instance_valid(overlay):
		return
	var impact := overlay.create_tween().set_parallel(true)
	impact.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	impact.tween_property(source_card, "global_position", merge_center - CREATURE_SLOT_SIZE * 0.5, impact_duration)
	impact.tween_property(target_card, "global_position", merge_center - CREATURE_SLOT_SIZE * 0.5, impact_duration)
	impact.tween_property(source_card, "scale", Vector2.ONE * 0.22, impact_duration)
	impact.tween_property(source_card, "rotation", deg_to_rad(38.0), impact_duration)
	impact.tween_property(source_card, "modulate:a", 0.0, impact_duration)
	impact.tween_property(target_card, "scale", Vector2.ONE * 1.22, impact_duration)
	impact.tween_property(burst, "scale", Vector2.ONE * 0.82, impact_duration)
	impact.tween_property(burst, "rotation", deg_to_rad(12.0), impact_duration)
	impact.tween_property(burst, "modulate:a", 1.0, impact_duration)
	await impact.finished

	if not is_instance_valid(overlay):
		return
	_set_merge_animation_card_quality(target_card, to_quality)
	var settle := overlay.create_tween().set_parallel(true)
	settle.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	settle.tween_property(
		target_card, "global_position", target_center - CREATURE_SLOT_SIZE * 0.5, settle_duration
	)
	settle.tween_property(target_card, "rotation", 0.0, settle_duration)
	settle.tween_property(target_card, "scale", Vector2.ONE, settle_duration)
	settle.tween_property(burst, "scale", Vector2.ONE * 1.08, settle_duration)
	settle.tween_property(burst, "modulate:a", 0.0, settle_duration)
	await settle.finished

	if not is_instance_valid(overlay):
		return
	var reveal := overlay.create_tween()
	reveal.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	reveal.tween_property(target_card, "modulate:a", 0.0, reveal_duration)
	await reveal.finished
	if is_instance_valid(overlay):
		overlay.queue_free()


func _create_merge_animation_card(item_texture: Texture2D, quality: StringName) -> Control:
	var card := Control.new()
	card.size = CREATURE_SLOT_SIZE
	card.pivot_offset = CREATURE_SLOT_SIZE * 0.5
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var background := TextureRect.new()
	background.texture = _get_creature_background_texture(item_texture)
	background.size = CREATURE_SLOT_SIZE
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_SCALE
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(background)

	var creature := TextureRect.new()
	creature.texture = item_texture
	creature.size = CREATURE_SLOT_SIZE
	creature.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	creature.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	creature.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(creature)

	var frame := TextureRect.new()
	frame.name = CREATURE_FRAME_NODE_NAME
	frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	frame.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.z_index = 1
	card.add_child(frame)

	var topper := Sprite2D.new()
	topper.name = CREATURE_TOPPER_NODE_NAME
	topper.texture = _get_creature_topper_texture()
	topper.position = CREATURE_TOPPER_CENTER
	topper.z_index = 2
	card.add_child(topper)
	_set_merge_animation_card_quality(card, quality)
	return card


func _set_merge_animation_card_quality(card: Control, quality: StringName) -> void:
	if card == null:
		return
	var frame := card.get_node_or_null(NodePath(CREATURE_FRAME_NODE_NAME)) as TextureRect
	if frame != null:
		frame.texture = _get_creature_frame_texture(quality)
		_layout_creature_frame(frame, quality)
	var topper := card.get_node_or_null(NodePath(CREATURE_TOPPER_NODE_NAME)) as Sprite2D
	if topper != null:
		var render_size := _get_creature_frame_render_size(quality)
		topper.scale = Vector2.ONE * (render_size.x / CREATURE_SLOT_SIZE.x)


func _get_merge_animation_burst_texture() -> Texture2D:
	if _merge_animation_burst_texture == null:
		_merge_animation_burst_texture = load(MERGE_ANIMATION_BURST_TEXTURE_PATH) as Texture2D
		if _merge_animation_burst_texture == null:
			push_warning("Merge animation burst is missing: %s" % MERGE_ANIMATION_BURST_TEXTURE_PATH)
	return _merge_animation_burst_texture


func _hold_control_for_merge(control: Control) -> void:
	if not is_instance_valid(control):
		return
	var instance_id := control.get_instance_id()
	if _merge_hidden_controls.has(instance_id):
		var existing: Dictionary = _merge_hidden_controls[instance_id]
		existing["count"] = int(existing.get("count", 0)) + 1
		_merge_hidden_controls[instance_id] = existing
		return

	_merge_hidden_controls[instance_id] = {
		"control": control,
		"count": 1,
		"modulate": control.modulate,
	}
	var hidden_modulate := control.modulate
	hidden_modulate.a = 0.0
	control.modulate = hidden_modulate


func _release_control_after_merge(control: Control) -> void:
	if not is_instance_valid(control):
		return
	var instance_id := control.get_instance_id()
	if not _merge_hidden_controls.has(instance_id):
		return

	var existing: Dictionary = _merge_hidden_controls[instance_id]
	var remaining := int(existing.get("count", 1)) - 1
	if remaining > 0:
		existing["count"] = remaining
		_merge_hidden_controls[instance_id] = existing
		return

	control.modulate = existing.get("modulate", Color.WHITE) as Color
	_merge_hidden_controls.erase(instance_id)


func _set_creature_item_texture(
	button: TextureButton,
	item_texture: Texture2D,
	quality: StringName = CREATURE_QUALITY_BRONZE
) -> void:
	if bool(button.get_meta(SHARED_PET_VIEW_META, false)):
		button.texture_normal = null
		var pet_view := _ensure_shared_pet_view(button)
		if item_texture == null:
			pet_view.call("clear_collection_data")
		else:
			var frame_render_size := _get_creature_frame_render_size(quality)
			pet_view.call("set_collection_data", {
				"texture_path": item_texture.resource_path,
				"quality": String(quality),
			}, {
				"slot_size": CREATURE_SLOT_SIZE,
				"background_texture": _get_creature_background_texture(item_texture),
				"sprite_texture": item_texture,
				"frame_texture": _get_creature_frame_texture(quality),
				"frame_position": (CREATURE_SLOT_SIZE - frame_render_size) * 0.5,
				"frame_size": frame_render_size,
				"topper_texture": _get_creature_topper_texture(),
				"topper_position": CREATURE_TOPPER_CENTER,
				"topper_scale": Vector2.ONE * (frame_render_size.x / CREATURE_SLOT_SIZE.x),
			})
		_refresh_merge_indicators()
		return
	button.texture_normal = item_texture
	button.set_meta("creature_quality", quality)
	var background := button.get_node_or_null(NodePath(CREATURE_BACKGROUND_NODE_NAME)) as TextureRect
	if background != null:
		background.texture = _get_creature_background_texture(item_texture)
		background.visible = item_texture != null

	var frame := button.get_node_or_null(NodePath(CREATURE_FRAME_NODE_NAME)) as TextureRect
	if frame != null:
		frame.texture = _get_creature_frame_texture(quality)
		_layout_creature_frame(frame, quality)
		frame.visible = item_texture != null

	var topper := button.get_node_or_null(NodePath(CREATURE_TOPPER_NODE_NAME)) as Sprite2D
	if topper != null:
		var frame_render_size := _get_creature_frame_render_size(quality)
		topper.scale = Vector2.ONE * (frame_render_size.x / CREATURE_SLOT_SIZE.x)
		topper.visible = item_texture != null

	_refresh_merge_indicators()


func _get_creature_background_texture(item_texture: Texture2D) -> Texture2D:
	if item_texture == null:
		return null

	var kind := _get_creature_background_kind(item_texture)
	if not _creature_background_textures.has(kind):
		# Background assets are baked to the 220 px content area so they cannot
		# extend beyond the unchanged 260 px decorative frame while dragging.
		var texture_path := CREATURE_BACKGROUND_TEXTURE_DIR.path_join("card_background_%s_220.png" % kind)
		_creature_background_textures[kind] = load(texture_path) as Texture2D

	return _creature_background_textures[kind] as Texture2D


func _get_creature_background_kind(item_texture: Texture2D) -> String:
	var file_name := item_texture.resource_path.get_file().to_lower()

	if _file_name_has_any(file_name, ["robot", "mech", "clockwork"]):
		return "mechanical"
	if _file_name_has_any(file_name, ["aqua", "water", "fish", "seahorse", "octopus", "crab", "sea", "bubble"]):
		return "water"
	if _file_name_has_any(file_name, ["fire", "flame", "lava", "magma", "phoenix", "reddragon"]):
		return "fire"
	if _file_name_has_any(file_name, ["ice", "frost", "snow", "penguin", "husky", "crystal"]):
		return "ice"
	if _file_name_has_any(file_name, ["wind", "cloud", "eagle", "hawk", "sparrow", "hummingbird", "butterfly", "winged"]):
		return "wind"
	if _file_name_has_any(file_name, ["light", "golden", "honeybee", "fairy", "unicorn"]):
		return "light"
	if _file_name_has_any(file_name, ["shadow", "night", "dark", "purple", "mystic", "hooded", "masked", "raven", "amethyst", "ink"]):
		return "shadow"
	if _file_name_has_any(file_name, ["stone", "rock", "mountain", "sand", "golem", "armadillo", "pangolin", "snail", "bull"]):
		return "earth"

	return "nature"


func _file_name_has_any(file_name: String, keywords: Array[String]) -> bool:
	for keyword in keywords:
		if file_name.contains(keyword):
			return true

	return false


func _prepare_sell_button() -> void:
	top_sell_button.visible = false
	top_sell_button.text = "\u51fa\u552e"
	top_sell_button.focus_mode = Control.FOCUS_NONE
	top_sell_button.mouse_filter = Control.MOUSE_FILTER_STOP
	top_sell_button.z_index = 200
	top_sell_button.add_theme_font_size_override("font_size", 48)
	top_sell_button.add_theme_color_override("font_color", Color(1.0, 0.9, 0.9, 1.0))
	top_sell_button.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0, 1.0))
	top_sell_button.add_theme_color_override("font_pressed_color", Color(1.0, 0.82, 0.82, 1.0))

	var normal_style := _make_sell_button_style(Color(0.85, 0.04, 0.04, 0.36), Color(1.0, 0.0, 0.0, 0.95))
	var hover_style := _make_sell_button_style(Color(0.95, 0.04, 0.04, 0.46), Color(1.0, 0.16, 0.16, 1.0))
	var pressed_style := _make_sell_button_style(Color(0.62, 0.0, 0.0, 0.54), Color(1.0, 0.08, 0.08, 1.0))
	top_sell_button.add_theme_stylebox_override("normal", normal_style)
	top_sell_button.add_theme_stylebox_override("hover", hover_style)
	top_sell_button.add_theme_stylebox_override("pressed", pressed_style)
	top_sell_button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())


func _prepare_clock_indicator() -> void:
	var main_bg := get_node_or_null("../..") as Control
	if main_bg == null:
		push_warning("Clock indicator cannot find MainBG.")
		return

	_clock_root = CLOCK_INDICATOR_SCENE.instantiate() as Node2D
	if _clock_root == null:
		push_warning("Clock indicator prefab could not be instantiated.")
		return
	_clock_root.position = CLOCK_POSITION
	_clock_root.z_index = 20
	main_bg.add_child.call_deferred(_clock_root)
	_clock_root.call("setup", _clock_total_hours, CLOCK_SIZE, false)


func _advance_clock_hour() -> void:
	_set_clock_total_hours(_clock_total_hours + 1)
	_save_clock_state()
	_update_clock_display(true)


func _set_clock_total_hours(total_hours: int) -> void:
	_clock_total_hours = max(0, total_hours)
	_clock_hour = _clock_total_hours % CLOCK_HOURS_PER_DAY
	_clock_day = int(_clock_total_hours / CLOCK_HOURS_PER_DAY) + 1


func _update_clock_display(animate_pointer: bool) -> void:
	if _clock_root == null:
		return
	_clock_root.call("set_total_hours", _clock_total_hours, animate_pointer)


func _make_sell_button_style(bg_color: Color, border_color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
	style.set_border_width_all(5)
	return style


func _show_initial_three_option() -> void:
	_is_transitioning = true
	_set_initial_state()
	await _play_animation(ANIM_SHOW_THREE_OPTION)
	_current_view = VIEW_THREE_OPTION
	_is_transitioning = false


func _set_initial_state() -> void:
	middle_three_option.visible = true
	middle_three_option.position = Vector2(1595.0, 76.0)

	middle_shop.visible = false
	middle_shop.position = Vector2(-1607.0, 20.0)

	middle_bag.visible = false
	middle_bag.position = Vector2(40.0, 837.0)

	top_shop.visible = false
	top_shop.position = Vector2(-600.0, 93.0)


func _on_three_option_button_pressed(option_index: int = -1) -> void:
	if _is_transitioning:
		return

	var option_kind := OPTION_SHOP
	if option_index >= 0 and option_index < _three_option_kinds.size():
		option_kind = _three_option_kinds[option_index]

	match option_kind:
		OPTION_BATTLE:
			_go_to_battle()
		OPTION_EVENT:
			_go_to_shop()
		_:
			_go_to_shop()


func _on_shop_back_button_pressed() -> void:
	if _is_transitioning or _current_view != VIEW_SHOP:
		return

	_go_to_three_option_from_shop()


func _on_bag_button_pressed() -> void:
	if _is_transitioning:
		return

	if _current_view == VIEW_BAG:
		_close_bag()
	else:
		_open_bag()


func _on_shop_button_down(shop_index: int) -> void:
	_hide_item_info_panel(DRAG_SOURCE_SHOP, shop_index)

	if _is_transitioning or _current_view != VIEW_SHOP:
		return

	if not _is_shop_item_available(shop_index):
		return

	_drag_candidate_source = DRAG_SOURCE_SHOP
	_drag_candidate_index = shop_index
	_drag_candidate_start = get_global_mouse_position()
	_is_dragging_shop_item = false


func _on_party_button_down(party_index: int) -> void:
	_start_storage_drag_candidate(DRAG_SOURCE_PARTY, party_index)


func _on_bag_slot_button_down(bag_index: int) -> void:
	_start_storage_drag_candidate(DRAG_SOURCE_BAG, bag_index)


func _start_storage_drag_candidate(source: StringName, item_index: int) -> void:
	if _is_transitioning or not _can_sell_storage_items():
		return

	if not _is_storage_item_available(source, item_index):
		return

	_hide_item_info_panel(source, item_index)
	_drag_candidate_source = source
	_drag_candidate_index = item_index
	_drag_candidate_start = get_global_mouse_position()
	_is_dragging_storage_item = false


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var keycode: int = event.keycode
		if keycode == KEY_NONE:
			keycode = event.physical_keycode
		_handle_shop_gold_cheat_key(keycode)

	if _drag_candidate_source == DRAG_SOURCE_NONE or _drag_candidate_index == -1:
		return

	if event is InputEventMouseMotion:
		var mouse_position := get_global_mouse_position()
		if not _has_active_drag() and _drag_candidate_start.distance_to(mouse_position) >= DRAG_START_DISTANCE:
			if _drag_candidate_source == DRAG_SOURCE_SHOP:
				_start_shop_item_drag()
			else:
				_start_storage_item_drag()

		if _has_active_drag():
			_update_drag_preview(mouse_position)

	if event is InputEventMouseButton:
		var mouse_button_event := event as InputEventMouseButton
		if mouse_button_event.button_index != MOUSE_BUTTON_LEFT or mouse_button_event.pressed:
			return

		var mouse_position := get_global_mouse_position()
		if _is_dragging_shop_item:
			_drop_dragged_shop_item(mouse_position)
		elif _is_dragging_storage_item:
			_drop_dragged_storage_item(mouse_position)

		_clear_drag_state()


func _go_to_shop() -> void:
	if _current_view != VIEW_THREE_OPTION:
		return

	_is_transitioning = true
	_hide_item_info_panel()
	_advance_clock_hour()
	_refresh_shop_items()
	await _play_animation(ANIM_HIDE_THREE_OPTION)
	await _play_animation(ANIM_SHOW_SHOP)
	_current_view = VIEW_SHOP
	_is_transitioning = false


func _go_to_battle() -> void:
	if _current_view != VIEW_THREE_OPTION:
		return

	_is_transitioning = true
	_hide_item_info_panel()
	_advance_clock_hour()
	_save_gold_state()
	_save_storage_state()
	await _play_animation(ANIM_HIDE_THREE_OPTION)

	var error := get_tree().change_scene_to_file(BATTLE_SCENE_PATH)
	if error != OK:
		push_warning("Failed to open battle scene: %s" % BATTLE_SCENE_PATH)
		await _play_animation(ANIM_SHOW_THREE_OPTION)
		_current_view = VIEW_THREE_OPTION
		_is_transitioning = false
		return


func _go_to_three_option_from_shop() -> void:
	_is_transitioning = true
	_hide_item_info_panel()
	await _play_animation(ANIM_HIDE_SHOP)
	_refresh_three_options()
	await _play_animation(ANIM_SHOW_THREE_OPTION)
	_current_view = VIEW_THREE_OPTION
	_is_transitioning = false


func _open_bag() -> void:
	_is_transitioning = true
	_hide_item_info_panel()
	_view_before_bag = _current_view

	if _view_before_bag == VIEW_SHOP:
		await _play_animation(ANIM_HIDE_SHOP)
	else:
		await _play_animation(ANIM_HIDE_THREE_OPTION)

	await _play_animation(ANIM_SHOW_BAG)
	_current_view = VIEW_BAG
	_is_transitioning = false


func _close_bag() -> void:
	_is_transitioning = true
	_hide_item_info_panel()
	await _play_animation(ANIM_HIDE_BAG)

	if _view_before_bag == VIEW_SHOP:
		await _play_animation(ANIM_SHOW_SHOP)
		_current_view = VIEW_SHOP
	else:
		await _play_animation(ANIM_SHOW_THREE_OPTION)
		_current_view = VIEW_THREE_OPTION

	_is_transitioning = false


func _play_animation(animation_name: StringName) -> void:
	if not animation_player.has_animation(animation_name):
		push_warning("Missing animation: %s" % animation_name)
		return

	animation_player.play(animation_name)
	await animation_player.animation_finished


func _refresh_shop_items() -> void:
	_hide_item_info_panel()

	var featured_creature_path := _shop_path("featured_creature_path", "res://FloatingUI/SpriteImages/Sprite_WhiteFox.png")
	var item_texture := load(featured_creature_path) as Texture2D
	if item_texture == null:
		push_warning("Shop sprite image not found: %s" % featured_creature_path)
		return

	for index in _shop_buttons.size():
		var button := _shop_buttons[index]
		var slot := _shop_slots[index]

		_shop_items[index] = item_texture
		_shop_item_qualities[index] = CREATURE_QUALITY_BRONZE
		slot.visible = true
		button.visible = true
		button.disabled = false
		_set_creature_item_texture(button, item_texture, _shop_item_qualities[index])
		button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED

	_refresh_shop_affordability()


func _purchase_shop_item(shop_index: int, target_kind: StringName = TARGET_AUTO, target_index: int = -1) -> bool:
	if not _is_shop_item_available(shop_index):
		return false

	if _gold < _shop_int("buy_price", 2):
		return false

	var item_texture: Texture2D = _shop_items[shop_index]
	var item_quality := _get_quality_at(_shop_item_qualities, shop_index)
	var merge_origin_button: Control = null
	if shop_index >= 0 and shop_index < _shop_buttons.size():
		merge_origin_button = _shop_buttons[shop_index]
	var was_added := false

	match target_kind:
		TARGET_PARTY:
			was_added = _receive_shop_item_in_storage(
				DRAG_SOURCE_PARTY, target_index, item_texture, item_quality, merge_origin_button
			)
		TARGET_BAG:
			if target_index >= 0:
				was_added = _receive_shop_item_in_storage(
					DRAG_SOURCE_BAG, target_index, item_texture, item_quality, merge_origin_button
				)
			else:
				was_added = _add_shop_item_to_first_empty_storage(item_texture, item_quality, true)
		_:
			was_added = _add_shop_item_to_first_empty_storage(item_texture, item_quality)

	if was_added:
		_change_gold(-_shop_int("buy_price", 2))
		_hide_shop_item(shop_index)
	else:
		push_warning("No valid party or bag target for this sprite.")

	return was_added


func _add_shop_item_to_first_empty_storage(item_texture: Texture2D, quality: StringName, bag_first := false) -> bool:
	var sources := [DRAG_SOURCE_BAG, DRAG_SOURCE_PARTY] if bag_first else [DRAG_SOURCE_PARTY, DRAG_SOURCE_BAG]
	for source in sources:
		var items := _bag_items if source == DRAG_SOURCE_BAG else _party_items
		for index in items.size():
			if items[index] == null:
				return _receive_shop_item_in_storage(source, index, item_texture, quality)

	return false


func _receive_shop_item_in_storage(
	source: StringName,
	slot_index: int,
	item_texture: Texture2D,
	quality: StringName,
	merge_origin_button: Control = null
) -> bool:
	if not _is_valid_storage_slot(source, slot_index):
		return false

	if _get_storage_item(source, slot_index) != null:
		return _merge_shop_item_into_storage_slot(
			source, slot_index, item_texture, quality, merge_origin_button
		)

	var was_added := _set_storage_item(source, slot_index, item_texture, quality)
	if was_added:
		var did_merge := _auto_merge_storage_item(source, slot_index)
		if source == DRAG_SOURCE_BAG and did_merge:
			_move_bag_merge_result_to_party(slot_index)

	return was_added


func _merge_shop_item_into_storage_slot(
	source: StringName,
	slot_index: int,
	item_texture: Texture2D,
	quality: StringName,
	merge_origin_button: Control = null
) -> bool:
	var current_item := _get_storage_item(source, slot_index)
	var current_quality := _get_storage_item_quality(source, slot_index)
	if current_item == null \
		or _get_merge_creature_key(current_item, current_quality) != _get_merge_creature_key(item_texture, quality):
		return false

	var upgraded_quality := _get_next_creature_quality(quality)
	if upgraded_quality == StringName():
		return false

	_queue_merge_animation(
		merge_origin_button,
		_get_storage_button(source, slot_index),
		item_texture,
		quality,
		upgraded_quality
	)
	if not _replace_storage_item(source, slot_index, item_texture, upgraded_quality):
		return false

	# The upgraded card may now match another owned card of its new quality.
	_auto_merge_storage_item(source, slot_index)
	if source == DRAG_SOURCE_BAG:
		_move_bag_merge_result_to_party(slot_index)
	return true


func _move_bag_merge_result_to_party(bag_index: int) -> bool:
	var item_texture := _get_storage_item(DRAG_SOURCE_BAG, bag_index)
	if item_texture == null:
		return false

	for party_index in _party_items.size():
		if _party_items[party_index] != null:
			continue

		var quality := _get_storage_item_quality(DRAG_SOURCE_BAG, bag_index)
		var bag_source_button := _get_storage_button(DRAG_SOURCE_BAG, bag_index)
		_clear_storage_item(DRAG_SOURCE_BAG, bag_index)
		var was_moved := _set_party_item(party_index, item_texture, quality)
		if was_moved:
			_retarget_queued_merge_animation(
				bag_source_button, _get_storage_button(DRAG_SOURCE_PARTY, party_index)
			)
		return was_moved

	return false


func _auto_merge_storage_item(source: StringName, slot_index: int) -> bool:
	var did_merge := false
	while true:
		var item_texture := _get_storage_item(source, slot_index)
		var quality := _get_storage_item_quality(source, slot_index)
		if item_texture == null:
			break

		var upgraded_quality := _get_next_creature_quality(quality)
		if upgraded_quality == StringName():
			break

		var matching_slot := _find_matching_storage_slot(source, slot_index, item_texture, quality)
		if matching_slot.is_empty():
			break

		var matching_source := StringName(matching_slot.get("source", DRAG_SOURCE_NONE))
		var matching_index := int(matching_slot.get("index", -1))
		_queue_merge_animation(
			_get_storage_button(matching_source, matching_index),
			_get_storage_button(source, slot_index),
			item_texture,
			quality,
			upgraded_quality
		)
		_clear_storage_item(matching_slot.source, matching_slot.index)
		if not _replace_storage_item(source, slot_index, item_texture, upgraded_quality):
			break
		did_merge = true

	if did_merge:
		_refresh_bag_capacity_bar()
	return did_merge


func _merge_all_storage_items() -> bool:
	var did_merge := false
	for source in [DRAG_SOURCE_PARTY, DRAG_SOURCE_BAG]:
		var items := _party_items if source == DRAG_SOURCE_PARTY else _bag_items
		for slot_index in items.size():
			if _auto_merge_storage_item(source, slot_index):
				did_merge = true

	return did_merge


func _find_matching_storage_slot(
	excluded_source: StringName,
	excluded_index: int,
	item_texture: Texture2D,
	quality: StringName
) -> Dictionary:
	var target_key := _get_merge_creature_key(item_texture, quality)
	for source in [DRAG_SOURCE_PARTY, DRAG_SOURCE_BAG]:
		var items := _party_items if source == DRAG_SOURCE_PARTY else _bag_items
		var qualities := _party_item_qualities if source == DRAG_SOURCE_PARTY else _bag_item_qualities
		for index in items.size():
			if source == excluded_source and index == excluded_index:
				continue
			var candidate := items[index] as Texture2D
			if candidate != null \
				and _get_merge_creature_key(candidate, _get_quality_at(qualities, index)) == target_key:
				return {"source": source, "index": index}

	return {}


func _get_next_creature_quality(quality: StringName) -> StringName:
	var quality_index := _quality_order.find(quality)
	if quality_index == -1 or quality_index >= _quality_order.size() - 1:
		return StringName()

	return _quality_order[quality_index + 1]


func _drop_dragged_shop_item(mouse_position: Vector2) -> void:
	var party_index := _find_slot_at_position(_party_slots, mouse_position)
	if party_index != -1:
		_purchase_shop_item(_drag_candidate_index, TARGET_PARTY, party_index)
		return

	if _is_point_inside_control(bag_button, mouse_position):
		_purchase_shop_item(_drag_candidate_index, TARGET_BAG)
		return

	if middle_bag.visible:
		var bag_index := _find_slot_at_position(_bag_slots, mouse_position)
		if bag_index != -1:
			_purchase_shop_item(_drag_candidate_index, TARGET_BAG, bag_index)


func _start_shop_item_drag() -> void:
	if not _is_shop_item_available(_drag_candidate_index):
		_clear_drag_state()
		return

	_hide_item_info_panel(DRAG_SOURCE_SHOP, _drag_candidate_index)
	_is_dragging_shop_item = true
	_create_drag_preview(
		_shop_items[_drag_candidate_index],
		_get_quality_at(_shop_item_qualities, _drag_candidate_index)
	)
	_update_drag_preview(get_global_mouse_position())


func _start_storage_item_drag() -> void:
	if not _is_storage_item_available(_drag_candidate_source, _drag_candidate_index):
		_clear_drag_state()
		return

	_hide_item_info_panel(_drag_candidate_source, _drag_candidate_index)
	_is_dragging_storage_item = true
	_set_sell_button_visible(true)
	_create_drag_preview(
		_get_storage_item(_drag_candidate_source, _drag_candidate_index),
		_get_storage_item_quality(_drag_candidate_source, _drag_candidate_index)
	)
	_update_drag_preview(get_global_mouse_position())


func _create_drag_preview(
	item_texture: Texture2D,
	quality: StringName = CREATURE_QUALITY_BRONZE
) -> void:
	_drag_preview = Control.new()
	# Make the dragged card use the same 220 x 220 content area as the cards in
	# the shop and inventory. The frame intentionally extends 20 px past this
	# area on each side, but the background and creature never do.
	_drag_preview.size = CREATURE_SLOT_SIZE
	_drag_preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_drag_preview.modulate = Color(1.0, 1.0, 1.0, 0.82)
	_drag_preview.z_index = 100

	var background := TextureRect.new()
	background.texture = _get_creature_background_texture(item_texture)
	background.size = CREATURE_SLOT_SIZE
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_SCALE
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_drag_preview.add_child(background)

	var creature := TextureRect.new()
	creature.texture = item_texture
	creature.size = CREATURE_SLOT_SIZE
	creature.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	creature.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	creature.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_drag_preview.add_child(creature)

	var frame_texture := _get_creature_frame_texture(quality)
	if frame_texture != null:
		var frame := Sprite2D.new()
		frame.texture = frame_texture
		frame.position = CREATURE_SLOT_SIZE * 0.5
		var frame_render_size := _get_creature_frame_render_size(quality)
		var frame_scale := frame_render_size.x / float(frame_texture.get_width())
		frame.scale = Vector2.ONE * frame_scale
		frame.z_index = 1
		_drag_preview.add_child(frame)

	var topper_texture := _get_creature_topper_texture()
	if topper_texture != null:
		var topper := Sprite2D.new()
		topper.texture = topper_texture
		topper.position = CREATURE_TOPPER_CENTER
		var frame_render_size := _get_creature_frame_render_size(quality)
		topper.scale = Vector2.ONE * (frame_render_size.x / CREATURE_SLOT_SIZE.x)
		topper.z_index = 2
		_drag_preview.add_child(topper)

	# Keep the preview in the UI canvas so it inherits exactly the same viewport
	# transform as the cards being dragged.
	get_tree().current_scene.add_child(_drag_preview)


func _update_drag_preview(mouse_position: Vector2) -> void:
	if _drag_preview == null:
		return

	_drag_preview.global_position = mouse_position - _drag_preview.size * 0.5


func _drop_dragged_storage_item(mouse_position: Vector2) -> void:
	if _drag_candidate_source == DRAG_SOURCE_PARTY:
		# The backpack icon is a valid drop target even while its panel is closed.
		# Dropping there stores the creature in the first available bag slot.
		if _is_point_inside_control(bag_button, mouse_position) \
			and _move_party_item_to_first_empty_bag(_drag_candidate_index):
			return

		if middle_bag.visible:
			var bag_index := _find_slot_at_position(_bag_slots, mouse_position)
			if bag_index != -1:
				_move_party_item_to_bag(_drag_candidate_index, bag_index)
				return

	if _drag_candidate_source == DRAG_SOURCE_BAG and middle_bag.visible:
		var party_index := _find_slot_at_position(_party_slots, mouse_position)
		if party_index != -1:
			_move_bag_item_to_party(_drag_candidate_index, party_index)
			return

	if not _is_point_inside_control(top_sell_button, mouse_position):
		return

	match _drag_candidate_source:
		DRAG_SOURCE_PARTY:
			_sell_party_item(_drag_candidate_index)
		DRAG_SOURCE_BAG:
			_sell_bag_item(_drag_candidate_index)


func _clear_drag_state() -> void:
	if _drag_preview != null:
		_drag_preview.queue_free()
		_drag_preview = null

	_set_sell_button_visible(false)
	_drag_candidate_source = DRAG_SOURCE_NONE
	_drag_candidate_index = -1
	_drag_candidate_start = Vector2.ZERO
	_is_dragging_shop_item = false
	_is_dragging_storage_item = false


func _handle_shop_gold_cheat_key(keycode: int) -> void:
	if _current_view != VIEW_SHOP or _is_transitioning:
		_shop_gold_cheat_index = 0
		return

	if keycode == int(SHOP_GOLD_CHEAT_SEQUENCE[_shop_gold_cheat_index]):
		_shop_gold_cheat_index += 1
		if _shop_gold_cheat_index >= SHOP_GOLD_CHEAT_SEQUENCE.size():
			_shop_gold_cheat_index = 0
			_change_gold(SHOP_GOLD_CHEAT_REWARD)
		return

	_shop_gold_cheat_index = 1 if keycode == int(SHOP_GOLD_CHEAT_SEQUENCE[0]) else 0


func _has_active_drag() -> bool:
	return _is_dragging_shop_item or _is_dragging_storage_item


func _can_sell_storage_items() -> bool:
	return _current_view == VIEW_SHOP or _current_view == VIEW_BAG


func _set_sell_button_visible(is_visible: bool) -> void:
	top_sell_button.visible = is_visible and _can_sell_storage_items()
	if top_sell_button.visible:
		top_sell_button.move_to_front()


func _is_shop_item_available(shop_index: int) -> bool:
	return shop_index >= 0 \
		and shop_index < _shop_items.size() \
		and _shop_items[shop_index] != null \
		and shop_index < _shop_slots.size() \
		and _shop_slots[shop_index].visible


func _hide_shop_item(shop_index: int) -> void:
	if shop_index < 0 or shop_index >= _shop_buttons.size():
		return

	_hide_item_info_panel(DRAG_SOURCE_SHOP, shop_index)
	_shop_items[shop_index] = null
	_shop_item_qualities[shop_index] = CREATURE_QUALITY_BRONZE
	_set_creature_item_texture(_shop_buttons[shop_index], null, CREATURE_QUALITY_BRONZE)
	_shop_buttons[shop_index].disabled = true
	_shop_buttons[shop_index].visible = false

	if shop_index < _shop_slots.size():
		_shop_slots[shop_index].visible = false


func _is_storage_item_available(source: StringName, item_index: int) -> bool:
	return _get_storage_item(source, item_index) != null


func _get_storage_button(source: StringName, item_index: int) -> TextureButton:
	match source:
		DRAG_SOURCE_PARTY:
			if item_index >= 0 and item_index < _party_buttons.size():
				return _party_buttons[item_index]
		DRAG_SOURCE_BAG:
			if item_index >= 0 and item_index < _bag_buttons.size():
				return _bag_buttons[item_index]

	return null


func _get_storage_item(source: StringName, item_index: int) -> Texture2D:
	match source:
		DRAG_SOURCE_PARTY:
			if item_index >= 0 and item_index < _party_items.size():
				return _party_items[item_index]
		DRAG_SOURCE_BAG:
			if item_index >= 0 and item_index < _bag_items.size():
				return _bag_items[item_index]

	return null


func _get_storage_item_quality(source: StringName, item_index: int) -> StringName:
	match source:
		DRAG_SOURCE_PARTY:
			return _get_quality_at(_party_item_qualities, item_index)
		DRAG_SOURCE_BAG:
			return _get_quality_at(_bag_item_qualities, item_index)

	return CREATURE_QUALITY_BRONZE


func _is_valid_storage_slot(source: StringName, slot_index: int) -> bool:
	match source:
		DRAG_SOURCE_PARTY:
			return slot_index >= 0 and slot_index < _party_items.size() and slot_index < _party_buttons.size()
		DRAG_SOURCE_BAG:
			return slot_index >= 0 and slot_index < _bag_items.size() and slot_index < _bag_buttons.size()

	return false


func _set_storage_item(
	source: StringName,
	slot_index: int,
	item_texture: Texture2D,
	quality: StringName
) -> bool:
	match source:
		DRAG_SOURCE_PARTY:
			return _set_party_item(slot_index, item_texture, quality)
		DRAG_SOURCE_BAG:
			return _set_bag_item(slot_index, item_texture, quality)

	return false


func _replace_storage_item(
	source: StringName,
	slot_index: int,
	item_texture: Texture2D,
	quality: StringName
) -> bool:
	if not _is_valid_storage_slot(source, slot_index) or _get_storage_item(source, slot_index) == null:
		return false

	_hide_item_info_panel(source, slot_index)
	match source:
		DRAG_SOURCE_PARTY:
			_party_items[slot_index] = item_texture
			_party_item_qualities[slot_index] = quality
			_set_creature_item_texture(_party_buttons[slot_index], item_texture, quality)
		DRAG_SOURCE_BAG:
			_bag_items[slot_index] = item_texture
			_bag_item_qualities[slot_index] = quality
			_set_creature_item_texture(_bag_buttons[slot_index], item_texture, quality)

	return true


func _clear_storage_item(source: StringName, slot_index: int) -> bool:
	if not _is_valid_storage_slot(source, slot_index) or _get_storage_item(source, slot_index) == null:
		return false

	_hide_item_info_panel(source, slot_index)
	match source:
		DRAG_SOURCE_PARTY:
			_party_items[slot_index] = null
			_party_item_qualities[slot_index] = CREATURE_QUALITY_BRONZE
			_set_creature_item_texture(_party_buttons[slot_index], null, CREATURE_QUALITY_BRONZE)
		DRAG_SOURCE_BAG:
			_bag_items[slot_index] = null
			_bag_item_qualities[slot_index] = CREATURE_QUALITY_BRONZE
			_set_creature_item_texture(_bag_buttons[slot_index], null, CREATURE_QUALITY_BRONZE)
			_refresh_bag_capacity_bar()

	return true


func _sell_party_item(slot_index: int) -> bool:
	if slot_index < 0 or slot_index >= _party_items.size() or slot_index >= _party_buttons.size():
		return false

	if _party_items[slot_index] == null:
		return false

	_clear_storage_item(DRAG_SOURCE_PARTY, slot_index)
	_change_gold(_shop_int("sell_price", 1))
	return true


func _sell_bag_item(slot_index: int) -> bool:
	if slot_index < 0 or slot_index >= _bag_items.size() or slot_index >= _bag_buttons.size():
		return false

	if _bag_items[slot_index] == null:
		return false

	_clear_storage_item(DRAG_SOURCE_BAG, slot_index)
	_change_gold(_shop_int("sell_price", 1))
	return true


func _move_party_item_to_bag(party_index: int, bag_index: int) -> bool:
	if party_index < 0 or party_index >= _party_items.size() or party_index >= _party_buttons.size():
		return false

	if bag_index < 0 or bag_index >= _bag_items.size() or bag_index >= _bag_buttons.size():
		return false

	var item_texture: Texture2D = _party_items[party_index]
	var quality := _get_quality_at(_party_item_qualities, party_index)
	if item_texture == null or _bag_items[bag_index] != null:
		return false

	_clear_storage_item(DRAG_SOURCE_PARTY, party_index)
	_set_bag_item(bag_index, item_texture, quality)
	_refresh_bag_capacity_bar()
	return true


func _move_bag_item_to_party(bag_index: int, party_index: int) -> bool:
	if bag_index < 0 or bag_index >= _bag_items.size() or bag_index >= _bag_buttons.size():
		return false

	if party_index < 0 or party_index >= _party_items.size() or party_index >= _party_buttons.size():
		return false

	var item_texture: Texture2D = _bag_items[bag_index]
	var quality := _get_quality_at(_bag_item_qualities, bag_index)
	if item_texture == null or _party_items[party_index] != null:
		return false

	_clear_storage_item(DRAG_SOURCE_BAG, bag_index)
	_set_party_item(party_index, item_texture, quality)
	_refresh_bag_capacity_bar()
	return true


func _move_party_item_to_first_empty_bag(party_index: int) -> bool:
	for bag_index in _bag_items.size():
		if _bag_items[bag_index] == null:
			return _move_party_item_to_bag(party_index, bag_index)

	return false


func _add_to_first_empty_party(
	item_texture: Texture2D,
	quality: StringName = CREATURE_QUALITY_BRONZE
) -> bool:
	for index in _party_items.size():
		if _party_items[index] == null:
			return _set_party_item(index, item_texture, quality)

	return false


func _add_to_first_empty_bag(
	item_texture: Texture2D,
	quality: StringName = CREATURE_QUALITY_BRONZE
) -> bool:
	for index in _bag_items.size():
		if _bag_items[index] == null:
			return _set_bag_item(index, item_texture, quality)

	return false


func _set_party_item(
	slot_index: int,
	item_texture: Texture2D,
	quality: StringName = CREATURE_QUALITY_BRONZE
) -> bool:
	if slot_index < 0 or slot_index >= _party_items.size() or slot_index >= _party_buttons.size():
		return false

	if _party_items[slot_index] != null:
		return false

	_party_items[slot_index] = item_texture
	_party_item_qualities[slot_index] = quality
	_set_creature_item_texture(_party_buttons[slot_index], item_texture, quality)
	_party_buttons[slot_index].visible = true
	return true


func _set_bag_item(
	slot_index: int,
	item_texture: Texture2D,
	quality: StringName = CREATURE_QUALITY_BRONZE
) -> bool:
	if slot_index < 0 or slot_index >= _bag_items.size() or slot_index >= _bag_buttons.size():
		return false

	if _bag_items[slot_index] != null:
		return false

	_bag_items[slot_index] = item_texture
	_bag_item_qualities[slot_index] = quality
	_set_creature_item_texture(_bag_buttons[slot_index], item_texture, quality)
	_bag_buttons[slot_index].visible = true
	_refresh_bag_capacity_bar()
	return true


func _find_slot_at_position(slots: Array[Control], mouse_position: Vector2) -> int:
	for index in slots.size():
		if _is_point_inside_control(slots[index], mouse_position):
			return index

	return -1


func _is_point_inside_control(control: Control, mouse_position: Vector2) -> bool:
	if control == null or not control.visible:
		return false

	return control.get_global_rect().has_point(mouse_position)


func _create_shop_info_panel() -> void:
	var panel_script := load(SPRITE_INFO_PANEL_SCRIPT_PATH) as Script
	if panel_script == null:
		push_warning("Sprite info panel script not found: %s" % SPRITE_INFO_PANEL_SCRIPT_PATH)
		return

	_shop_info_panel = panel_script.new() as Control
	_shop_info_panel.name = "ShopInfoPreview"
	_shop_info_panel.visible = false
	_shop_info_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_shop_info_panel.z_index = 300
	get_tree().current_scene.add_child.call_deferred(_shop_info_panel)


func _on_shop_button_mouse_entered(shop_index: int) -> void:
	_show_item_info_panel(DRAG_SOURCE_SHOP, shop_index)


func _on_shop_button_mouse_exited(shop_index: int) -> void:
	_hide_item_info_panel(DRAG_SOURCE_SHOP, shop_index)


func _on_party_button_mouse_entered(party_index: int) -> void:
	_show_item_info_panel(DRAG_SOURCE_PARTY, party_index)


func _on_party_button_mouse_exited(party_index: int) -> void:
	_hide_item_info_panel(DRAG_SOURCE_PARTY, party_index)


func _on_bag_button_mouse_entered(bag_index: int) -> void:
	_show_item_info_panel(DRAG_SOURCE_BAG, bag_index)


func _on_bag_button_mouse_exited(bag_index: int) -> void:
	_hide_item_info_panel(DRAG_SOURCE_BAG, bag_index)


func _show_item_info_panel(source: StringName, item_index: int) -> void:
	if _is_transitioning or _has_active_drag():
		return

	var info_data := _get_info_data_for_source(source, item_index)
	if info_data == null or _shop_info_panel == null:
		return

	var panel_size := _get_shop_info_panel_size()
	_hovered_info_source = source
	_hovered_info_index = item_index
	_shop_info_panel.custom_minimum_size = panel_size
	_shop_info_panel.size = panel_size
	_shop_info_panel.global_position = _get_shop_info_panel_position(panel_size)
	_shop_info_panel.call("display_info", info_data)
	_shop_info_panel.visible = true
	_shop_info_panel.move_to_front()


func _hide_item_info_panel(source: StringName = DRAG_SOURCE_NONE, item_index: int = -1) -> void:
	if source != DRAG_SOURCE_NONE and (_hovered_info_source != source or _hovered_info_index != item_index):
		return

	_hovered_info_source = DRAG_SOURCE_NONE
	_hovered_info_index = -1
	if _shop_info_panel != null:
		_shop_info_panel.visible = false


func _get_shop_info_panel_size() -> Vector2:
	var viewport_size := get_viewport_rect().size
	var available_width = max(viewport_size.x - SHOP_INFO_PANEL_LEFT_EDGE - SHOP_INFO_PANEL_RIGHT_MARGIN, 1.0)
	var available_height = max(viewport_size.y - SHOP_INFO_PANEL_VERTICAL_MARGIN * 2.0, 1.0)
	return Vector2(available_width, min(available_width * SHOP_INFO_PANEL_ASPECT_HEIGHT_RATIO, available_height))


func _get_shop_info_panel_position(panel_size: Vector2) -> Vector2:
	var viewport_size := get_viewport_rect().size
	var x = max(viewport_size.x - panel_size.x - SHOP_INFO_PANEL_RIGHT_MARGIN, SHOP_INFO_PANEL_LEFT_EDGE)
	var y = max((viewport_size.y - panel_size.y) * 0.5, SHOP_INFO_PANEL_VERTICAL_MARGIN)
	return Vector2(x, y)


func _get_info_data_for_source(source: StringName, item_index: int) -> SpriteInfoData:
	var item_texture: Texture2D = null
	var quality := CREATURE_QUALITY_BRONZE

	match source:
		DRAG_SOURCE_SHOP:
			if _current_view != VIEW_SHOP or not _is_shop_item_available(item_index):
				return null
			item_texture = _shop_items[item_index] as Texture2D
			quality = _get_quality_at(_shop_item_qualities, item_index)
		DRAG_SOURCE_PARTY, DRAG_SOURCE_BAG:
			if not _is_storage_item_available(source, item_index):
				return null
			item_texture = _get_storage_item(source, item_index)
			quality = _get_storage_item_quality(source, item_index)
		_:
			return null

	return _get_info_data_for_item(item_texture, quality)


func _get_info_data_for_item(item_texture: Texture2D, quality: StringName) -> SpriteInfoData:
	if item_texture == null:
		return null

	var info_data: SpriteInfoData = null
	if _sprite_info_database != null:
		var configured_info := _sprite_info_database.get_info_for_texture(item_texture)
		if configured_info != null:
			info_data = configured_info.duplicate(true) as SpriteInfoData
		else:
			info_data = _sprite_info_database.make_default_info(item_texture)
	else:
		var fallback_database := SpriteInfoDatabase.new()
		info_data = fallback_database.make_default_info(item_texture)

	_apply_card_quality_to_info(info_data, quality)
	return info_data


func _apply_card_quality_to_info(info_data: SpriteInfoData, quality: StringName) -> void:
	if info_data == null:
		return
	if info_data.ranks.is_empty():
		info_data.ranks.append(SpriteRankStats.new())

	var rank := info_data.get_current_rank()
	rank.quality_icon = null
	match _normalize_creature_quality(quality):
		CREATURE_QUALITY_SILVER:
			rank.quality_name = "白银"
			rank.quality_color = Color(0.68, 0.70, 0.72, 1.0)
		CREATURE_QUALITY_GOLD:
			rank.quality_name = "黄金"
			rank.quality_color = Color(0.95, 0.62, 0.08, 1.0)
		CREATURE_QUALITY_DIAMOND:
			rank.quality_name = "钻石"
			rank.quality_color = Color(0.45, 0.72, 1.0, 1.0)
		_:
			rank.quality_name = "青铜"
			rank.quality_color = Color(0.55, 0.32, 0.18, 1.0)


func _load_sprite_info_database() -> void:
	var loaded_database := load(SPRITE_INFO_DATABASE_PATH)
	if loaded_database is SpriteInfoDatabase:
		_sprite_info_database = loaded_database
	else:
		push_warning("Sprite info database not found or invalid: %s" % SPRITE_INFO_DATABASE_PATH)
		_sprite_info_database = SpriteInfoDatabase.new()


func _load_textures_from_folder(folder_path: String) -> Array[Texture2D]:
	var textures: Array[Texture2D] = []
	var dir := DirAccess.open(folder_path)
	if dir == null:
		push_warning("Image folder not found: %s" % folder_path)
		return textures

	var file_names := dir.get_files()
	file_names.sort()

	for file_name in file_names:
		if file_name.get_extension().to_lower() != "png":
			continue
		if file_name.begins_with("UI_"):
			continue

		var texture := load(folder_path.path_join(file_name)) as Texture2D
		if texture != null:
			textures.append(texture)

	return textures


func _get_texture_buttons(root: Node) -> Array[TextureButton]:
	var buttons: Array[TextureButton] = []
	_collect_texture_buttons(root, buttons)
	return buttons


func _get_direct_control_children(root: Node) -> Array[Control]:
	var controls: Array[Control] = []
	for child in root.get_children():
		if child is Control:
			controls.append(child)

	return controls


func _collect_texture_buttons(node: Node, buttons: Array[TextureButton]) -> void:
	if node is TextureButton:
		buttons.append(node)

	for child in node.get_children():
		_collect_texture_buttons(child, buttons)
