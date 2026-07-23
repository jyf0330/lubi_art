extends SceneTree

const BATTLE_CONTROLLER := "res://Features/Battle/Controllers/BattleBoardController.gd"
const ARTIST_CONTROLLER := "res://Features/ArtistFlow/Controllers/ArtistFlowPreviewController.gd"

const PREFABS := [
	"res://Shared/Prefabs/Pet/CollectionPetView.tscn",
	"res://Shared/Prefabs/Pet/SpriteInfoPanel.tscn",
	"res://Shared/Prefabs/Pet/SpriteInfo/SpriteInfoHeaderView.tscn",
	"res://Shared/Prefabs/Pet/SpriteInfo/SpriteInfoAttackPatternView.tscn",
	"res://Shared/Prefabs/Pet/SpriteInfo/SpriteInfoAttackCellView.tscn",
	"res://Shared/Prefabs/Pet/SpriteInfo/SpriteInfoStatTableView.tscn",
	"res://Shared/Prefabs/Pet/SpriteInfo/SpriteInfoStatRowView.tscn",
	"res://Features/ArtistFlow/Prefabs/Effects/MergeBurstView.tscn",
	"res://Features/Battle/Prefabs/Board/BattleTextureMarkerView.tscn",
	"res://Features/Battle/Prefabs/Board/ElementTrapView.tscn",
]

const FORBIDDEN_BATTLE_ACCESS := [
	"get_node(\"UnitShadow\")",
	"get_node(\"Sprite\")",
	"get_node(\"HpLabel\")",
	"get_node(\"DamagePreviewLabel\")",
]

const FORBIDDEN_ARTIST_ACCESS := [
	"../Party/Party_Container",
	"../Top/Top_Sell",
	"../Top/Top_Shop",
	"../Bags/AbilityBar",
	"TextureRect.new()",
	"Sprite2D.new()",
	"Label.new()",
]


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	if not _assert_source_boundary(BATTLE_CONTROLLER, FORBIDDEN_BATTLE_ACCESS):
		return
	if not _assert_source_boundary(ARTIST_CONTROLLER, FORBIDDEN_ARTIST_ACCESS):
		return

	for path in PREFABS:
		var packed := load(path) as PackedScene
		if packed == null:
			_fail("Required prefab cannot be loaded: %s" % path)
			return
		var instance := packed.instantiate()
		if instance == null:
			_fail("Required prefab cannot be instantiated: %s" % path)
			return
		instance.free()

	print("ART_ARCHITECTURE_BOUNDARIES_OK prefabs=%d" % PREFABS.size())
	quit()


func _assert_source_boundary(path: String, forbidden: Array) -> bool:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		_fail("Cannot read controller source: %s" % path)
		return false
	var source := file.get_as_text()
	for fragment in forbidden:
		if source.contains(fragment):
			_fail("Controller crossed a prefab boundary: %s contains %s" % [path, fragment])
			return false
	return true


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
