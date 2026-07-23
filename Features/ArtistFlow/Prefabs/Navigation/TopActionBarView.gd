extends NinePatchRect
class_name TopActionBarView

signal back_requested
signal sell_requested

var back_button: TextureButton
var sell_button: Button
var back_panel: GridContainer


func _ready() -> void:
	_bind_nodes()
	if not back_button.pressed.is_connected(_emit_back_requested):
		back_button.pressed.connect(_emit_back_requested)
	if not sell_button.pressed.is_connected(_emit_sell_requested):
		sell_button.pressed.connect(_emit_sell_requested)
	_configure_sell_button()


func setup(view_model: Dictionary) -> void:
	_bind_nodes()
	back_button.visible = bool(view_model.get("back_visible", true))
	sell_button.visible = bool(view_model.get("sell_visible", true))


func refresh(view_model: Dictionary) -> void:
	setup(view_model)


func get_back_button() -> TextureButton:
	_bind_nodes()
	return back_button


func get_sell_button() -> Button:
	_bind_nodes()
	return sell_button


func set_back_panel_state(is_visible: bool, panel_position: Vector2) -> void:
	_bind_nodes()
	back_panel.visible = is_visible
	back_panel.position = panel_position


func set_sell_available(is_available: bool) -> void:
	_bind_nodes()
	sell_button.visible = is_available
	if is_available:
		sell_button.move_to_front()


func contains_sell_point(point: Vector2) -> bool:
	_bind_nodes()
	return sell_button.is_visible_in_tree() and sell_button.get_global_rect().has_point(point)


func _configure_sell_button() -> void:
	_bind_nodes()
	sell_button.visible = false
	sell_button.text = "出售"
	sell_button.focus_mode = Control.FOCUS_NONE
	sell_button.mouse_filter = Control.MOUSE_FILTER_STOP
	sell_button.z_index = 200
	sell_button.add_theme_font_size_override("font_size", 48)
	sell_button.add_theme_color_override("font_color", Color(1.0, 0.9, 0.9, 1.0))
	sell_button.add_theme_color_override("font_hover_color", Color.WHITE)
	sell_button.add_theme_color_override("font_pressed_color", Color(1.0, 0.82, 0.82, 1.0))
	sell_button.add_theme_stylebox_override(
		"normal", _make_sell_button_style(Color(0.85, 0.04, 0.04, 0.36), Color(1.0, 0.0, 0.0, 0.95))
	)
	sell_button.add_theme_stylebox_override(
		"hover", _make_sell_button_style(Color(0.95, 0.04, 0.04, 0.46), Color(1.0, 0.16, 0.16, 1.0))
	)
	sell_button.add_theme_stylebox_override(
		"pressed", _make_sell_button_style(Color(0.62, 0.0, 0.0, 0.54), Color(1.0, 0.08, 0.08, 1.0))
	)
	sell_button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())


func _make_sell_button_style(bg_color: Color, border_color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
	style.set_border_width_all(5)
	return style


func _bind_nodes() -> void:
	if back_panel == null:
		back_panel = get_node_or_null("Top_Shop") as GridContainer
	if back_button == null:
		back_button = get_node_or_null("Top_Shop/Shop_BackButton") as TextureButton
	if sell_button == null:
		sell_button = get_node_or_null("Top_Sell") as Button


func _emit_back_requested() -> void:
	back_requested.emit()


func _emit_sell_requested() -> void:
	sell_requested.emit()
