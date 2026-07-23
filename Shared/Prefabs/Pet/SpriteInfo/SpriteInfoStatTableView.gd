@tool
extends PanelContainer
class_name SpriteInfoStatTableView

@onready var hp_row: SpriteInfoStatRowView = $StatsMargin/StatsRows/HpRow
@onready var ap_row: SpriteInfoStatRowView = $StatsMargin/StatsRows/ApRow
@onready var attack_row: SpriteInfoStatRowView = $StatsMargin/StatsRows/AttackRow
@onready var defense_row: SpriteInfoStatRowView = $StatsMargin/StatsRows/DefenseRow
@onready var shield_row: SpriteInfoStatRowView = $StatsMargin/StatsRows/ShieldRow
@onready var regen_row: SpriteInfoStatRowView = $StatsMargin/StatsRows/RegenRow


func refresh(rank: SpriteRankStats, art_textures: Dictionary) -> void:
	hp_row.refresh("%d/%d" % [rank.hp_current, rank.hp_max], art_textures)
	ap_row.refresh("%d/%d" % [rank.ap_current, rank.ap_max], art_textures)
	attack_row.refresh(str(rank.attack), art_textures)
	defense_row.refresh(str(rank.defense), art_textures)
	shield_row.refresh(str(rank.shield), art_textures)
	regen_row.refresh(str(rank.regen), art_textures)


func clear() -> void:
	for row in [hp_row, ap_row, attack_row, defense_row, shield_row, regen_row]:
		row.clear()
