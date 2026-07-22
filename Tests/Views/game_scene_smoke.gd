extends SceneTree

const GAME_SCENE := "res://Game/Scenes/game.tscn"


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var packed_scene := load(GAME_SCENE) as PackedScene
	if packed_scene == null:
		_fail("Unable to load game main scene")
		return

	var game := packed_scene.instantiate() as Control
	root.add_child(game)
	await process_frame
	await process_frame

	if game.name != "game":
		_fail("Main scene root must be named game")
		return
	if game.call("get_current_screen_id") != &"battle":
		_fail("game did not load the battle screen through its controller")
		return

	var battle := game.call("get_current_screen") as Control
	if battle == null or battle.get_node_or_null("BoardGrid") == null:
		_fail("game battle screen is missing its BoardGrid")
		return

	print("game scene smoke test passed.")
	quit()


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
