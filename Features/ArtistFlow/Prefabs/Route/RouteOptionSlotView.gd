extends PanelContainer
class_name RouteOptionSlotView

## Stateful route-card art prefab. It owns its logo and input surface while
## route choice semantics remain in the ArtistFlow controller.

signal option_requested(kind: StringName)

@export var button_path: NodePath

var _kind: StringName = &""
var _button: TextureButton
var _logo: TextureRect


func _ready() -> void:
	_bind_nodes()


func setup(view_model: Dictionary) -> void:
	_bind_nodes()
	_kind = StringName(view_model.get("kind", &""))
	if _button != null:
		_button.disabled = bool(view_model.get("disabled", false))
	if _logo != null:
		_logo.texture = view_model.get("logo") as Texture2D
		_logo.visible = _logo.texture != null


func refresh(view_model: Dictionary) -> void:
	setup(view_model)


func get_button() -> TextureButton:
	_bind_nodes()
	return _button


func get_kind() -> StringName:
	return _kind


func _bind_nodes() -> void:
	if _button == null:
		if not button_path.is_empty():
			_button = get_node_or_null(button_path) as TextureButton
		if _button == null:
			_button = _find_texture_button(self)
	if _logo == null:
		_logo = get_node_or_null("OptionLogo") as TextureRect
	if _button != null and not _button.pressed.is_connected(_on_pressed):
		_button.pressed.connect(_on_pressed)


func _find_texture_button(node: Node) -> TextureButton:
	for child in node.get_children():
		if child is TextureButton:
			return child as TextureButton
		var nested := _find_texture_button(child)
		if nested != null:
			return nested
	return null


func _on_pressed() -> void:
	option_requested.emit(_kind)
