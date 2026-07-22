@tool
extends Sprite2D
class_name MonsterBiteEffect

@export var hit_frame_index := 3
@export var frame_durations: Array[float] = [0.083, 0.067, 0.033, 0.1, 0.067]

const FRAMES: Array[Texture2D] = [
	preload("res://Battle/Prefabs/Monster_Bite/frames/monster_teeth_bite_01.png"),
	preload("res://Battle/Prefabs/Monster_Bite/frames/monster_teeth_bite_02.png"),
	preload("res://Battle/Prefabs/Monster_Bite/frames/monster_teeth_bite_03.png"),
	preload("res://Battle/Prefabs/Monster_Bite/frames/monster_teeth_bite_04.png"),
	preload("res://Battle/Prefabs/Monster_Bite/frames/monster_teeth_bite_05.png"),
]


func play(hit_callback := Callable()) -> void:
	for frame_index in FRAMES.size():
		texture = FRAMES[frame_index]
		if frame_index == hit_frame_index and hit_callback.is_valid():
			hit_callback.call()
		var duration := frame_durations[frame_index] if frame_index < frame_durations.size() else 0.08
		await get_tree().create_timer(duration).timeout
	queue_free()
