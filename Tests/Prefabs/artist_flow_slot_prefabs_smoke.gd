extends SceneTree

const ARTIST_FLOW_SCENE := "res://Features/ArtistFlow/Views/ArtistFlowView.tscn"
const SLOT_PATHS := [
	"MainBG/Containers/Party/Party_Container/Party_Slot",
	"MainBG/Containers/Middle/Middle_Shop/Shop_Slot",
	"MainBG/Containers/Middle/Middle_Bag/Bag_Slot",
	"MainBG/Containers/Middle/Middle_Three_Option/Three_Option_Slot",
]


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var error := change_scene_to_file(ARTIST_FLOW_SCENE)
	if error != OK:
		_fail("Unable to load ArtistFlowView")
		return
	await process_frame
	await process_frame

	for slot_path in SLOT_PATHS:
		var slot := current_scene.get_node_or_null(slot_path) as Control
		if slot == null:
			_fail("Missing scripted slot: %s" % slot_path)
			return
		if not slot.has_method("setup") or not slot.has_method("refresh"):
			_fail("Slot has no public presentation API: %s" % slot_path)
			return
		if not slot.has_method("get_button") or slot.call("get_button") == null:
			_fail("Slot does not expose its input surface: %s" % slot_path)
			return

	print("ArtistFlow scripted slot prefab smoke test passed.")
	quit()


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
