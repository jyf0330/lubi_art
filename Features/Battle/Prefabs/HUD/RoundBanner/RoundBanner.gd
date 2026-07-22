@tool
extends Control
class_name RoundBannerView

signal playback_finished

@export_range(0.0, 2.0, 0.01) var fade_in_duration := 0.18
@export_range(0.0, 5.0, 0.05) var hold_duration := 1.0
@export_range(0.0, 2.0, 0.01) var fade_out_duration := 0.22

@onready var _banner_group: Control = $Banner
@onready var _banner_texture: TextureRect = $Banner/BannerTexture
@onready var _title: Label = $Banner/Title
@onready var _subtitle: Label = $Banner/Subtitle


func setup(round_number: int, subtitle := "我方回合") -> void:
	_title.text = "第%d回合" % round_number
	_subtitle.text = subtitle


func play() -> void:
	_layout_banner()
	modulate.a = 0.0
	_banner_group.scale = Vector2.ONE * 0.96

	var fade_in := create_tween()
	fade_in.set_parallel(true)
	fade_in.tween_property(self, "modulate:a", 1.0, fade_in_duration)
	fade_in.tween_property(_banner_group, "scale", Vector2.ONE, fade_in_duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await fade_in.finished
	await get_tree().create_timer(hold_duration).timeout

	var fade_out := create_tween()
	fade_out.set_parallel(true)
	fade_out.tween_property(self, "modulate:a", 0.0, fade_out_duration)
	fade_out.tween_property(_banner_group, "scale", Vector2.ONE * 1.02, fade_out_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	await fade_out.finished
	playback_finished.emit()
	queue_free()


func _layout_banner() -> void:
	var viewport_size := get_viewport_rect().size
	var texture_size := _banner_texture.texture.get_size()
	var target_width: float = min(viewport_size.x * 0.88, texture_size.x)
	var scale_factor := target_width / texture_size.x
	var banner_size := texture_size * scale_factor
	_banner_group.position = (viewport_size - banner_size) * 0.5 + Vector2(0.0, -18.0)
	_banner_group.size = banner_size
	_banner_group.pivot_offset = banner_size * 0.5
	_banner_texture.size = banner_size
	_title.position = Vector2(0.0, 352.0 * scale_factor)
	_title.size = Vector2(banner_size.x, 126.0 * scale_factor)
	_title.add_theme_font_size_override("font_size", int(max(44.0, round(88.0 * scale_factor))))
	_subtitle.position = Vector2(0.0, 500.0 * scale_factor)
	_subtitle.size = Vector2(banner_size.x, 58.0 * scale_factor)
	_subtitle.add_theme_font_size_override("font_size", int(max(26.0, round(38.0 * scale_factor))))
