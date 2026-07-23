extends Control

@onready var panel: SpriteInfoPanel = $PreviewFrame/SpriteInfoPanel


func _ready() -> void:
	var rank := SpriteRankStats.new()
	rank.quality_name = "钻石"
	rank.quality_color = Color(0.45, 0.72, 1.0, 1.0)
	rank.hp_current = 24
	rank.hp_max = 24
	rank.ap_current = 3
	rank.ap_max = 3
	rank.attack = 4
	rank.defense = 2
	rank.shield = 1
	rank.regen = 1

	var info := SpriteInfoData.new()
	info.sprite_id = "pal_013"
	info.display_name = "叶泥泥"
	info.element_name = "土属性"
	info.origin_cell_index = 10
	info.hit_cell_indices = [3, 9, 11, 17]
	info.ranks = [rank]
	panel.display_info(info)
