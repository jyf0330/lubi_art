extends SceneTree

const COLLECTION_PET_PREFAB := "res://Shared/Prefabs/Pet/CollectionPetView.tscn"
const INDICATOR_TEXTURE := "res://Features/ArtistFlow/Art/UI/Images/Indicators/sprite_merge_upgrade_chevrons_220.png"
const EXPECTED_OPACITY := 0.72
const EXPECTED_REPEAT_OFFSET := 220.0
const EXPECTED_LOOP_DURATION := 1.15


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var packed := load(COLLECTION_PET_PREFAB) as PackedScene
	var pet_view := packed.instantiate() as Control
	root.add_child(pet_view)
	pet_view.call("setup", {"slot_size": Vector2(220.0, 220.0)})
	pet_view.call("set_merge_indicator", load(INDICATOR_TEXTURE), EXPECTED_OPACITY, true)
	var indicator := pet_view.get_node("MergeIndicatorClip/Indicator") as TextureRect
	if indicator == null:
		_fail("The merge indicator was not created.")
		return
	var follower := indicator.get_node_or_null("Follower") as TextureRect
	if follower == null:
		_fail("The merge indicator has no follower entering from below.")
		return
	if not is_equal_approx(follower.position.y, EXPECTED_REPEAT_OFFSET):
		_fail("The follower is not positioned one card below the leading indicator.")
		return

	var start_y := indicator.position.y
	await create_timer(0.24).timeout
	var later_y := indicator.position.y
	if later_y >= start_y - 12.0:
		_fail("The merge indicator did not move visibly upward.")
		return
	if not is_equal_approx(indicator.modulate.a, EXPECTED_OPACITY):
		_fail("The merge indicator opacity is not the intended high-contrast value.")
		return

	# Sample either side of the wrap: the leading image must restart at the top
	# while its identical follower seamlessly replaces it there.
	await create_timer(EXPECTED_LOOP_DURATION - 0.30).timeout
	var before_wrap_y := indicator.position.y
	await create_timer(0.12).timeout
	var after_wrap_y := indicator.position.y
	if after_wrap_y <= before_wrap_y:
		_fail(
			"The merge indicator did not wrap into a repeating loop (%s -> %s)."
			% [before_wrap_y, after_wrap_y]
		)
		return
	if not is_equal_approx(follower.position.y, EXPECTED_REPEAT_OFFSET):
		_fail("The follower no longer keeps the seamless repeat offset.")
		return

	print("Merge indicator animation smoke test passed.")
	pet_view.queue_free()
	await process_frame
	quit()


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
