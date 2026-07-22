extends SceneTree

const BATTLE_SCENE := "res://Battle/Scenes/battle_main_scene.tscn"


func _initialize() -> void:
	_capture.call_deferred()


func _capture() -> void:
	var error := change_scene_to_file(BATTLE_SCENE)
	if error != OK:
		quit(1)
		return

	await process_frame
	await process_frame
	await process_frame
	await create_timer(1.6).timeout
	var image := root.get_texture().get_image()
	error = image.save_png("res://output/status-badges-preview.png")
	quit(0 if error == OK else 1)
