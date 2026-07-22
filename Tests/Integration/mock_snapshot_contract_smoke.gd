extends SceneTree

const PROVIDER_SCRIPT := preload("res://PreviewData/Providers/GameDataProvider.gd")


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var provider = PROVIDER_SCRIPT.new()
	if not provider.is_using_mock_data():
		_fail("Preview provider must identify its current source as mock data")
		return

	var snapshot: Dictionary = provider.get_snapshot()
	for key in [
		"phase", "stateVersion", "stateHash", "coins", "leaders", "units",
		"board", "roster", "shop_offers", "inventory", "viewModel"
	]:
		if not snapshot.has(key):
			_fail("Mock snapshot is missing godot-latest contract field: %s" % key)
			return

	var board := Dictionary(snapshot.get("board", {}))
	var dimensions := Dictionary(board.get("dimensions", {}))
	var width := int(board.get("width", dimensions.get("width", 0)))
	var height := int(board.get("height", dimensions.get("height", 0)))
	if width != 8 or height != 7:
		_fail("Mock snapshot board dimensions are not the authored 8x7 preview")
		return
	if Array(board.get("cells", [])).size() != width * height:
		_fail("Mock snapshot board must expose one cell record per board position")
		return

	var units: Array[Dictionary] = provider.get_battle_units()
	if units.size() < 4:
		_fail("Battle projection did not include leaders and snapshot units")
		return
	for unit in units:
		for key in ["id", "coord", "team", "hp", "max_hp", "attack_damage"]:
			if not unit.has(key):
				_fail("Battle projection is missing presentation field: %s" % key)
				return

	var shop_data: Dictionary = provider.get_shop_data()
	var offers := Array(shop_data.get("offers", []))
	if offers.size() != Array(snapshot.get("shop_offers", [])).size():
		_fail("Shop projection does not preserve snapshot offer count")
		return
	for offer_value in offers:
		var offer := Dictionary(offer_value)
		if String(offer.get("offer_id", "")).is_empty() or int(offer.get("price", -1)) < 0:
			_fail("Shop projection lost the real offer id/price contract")
			return
		if String(offer.get("texture_path", "")).is_empty():
			_fail("Shop presentation adapter did not resolve an art texture")
			return

	var replacement := snapshot.duplicate(true)
	replacement["coins"] = 77
	var replacement_view_model := Dictionary(replacement.get("viewModel", {})).duplicate(true)
	replacement_view_model["coins"] = 77
	replacement["viewModel"] = replacement_view_model
	provider.set_snapshot(replacement)
	if int(provider.get_view_model().get("coins", -1)) != 77:
		_fail("Provider snapshot override did not use the injected real-data boundary")
		return

	print("Mock snapshot contract smoke test passed.")
	quit()


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
