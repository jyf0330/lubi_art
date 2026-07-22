extends PanelContainer
class_name CreatureSlotView

## Scripted art prefab shared by shop, party, and bag slots.
## The controller supplies presentation data; this prefab owns its visuals and
## converts low-level button events into a stable signal contract.

signal pressed(slot: CreatureSlotView)
signal pointer_entered(slot: CreatureSlotView)
signal pointer_exited(slot: CreatureSlotView)

@export var button_path: NodePath

var _view_model: Dictionary = {}
var _button: TextureButton


func _ready() -> void:
	_bind_button()


func setup(view_model: Dictionary) -> void:
	_view_model = view_model.duplicate(true)
	_bind_button()
	if _button == null:
		return
	_button.texture_normal = view_model.get("texture") as Texture2D
	_button.disabled = bool(view_model.get("disabled", false))
	_button.visible = bool(view_model.get("visible", true))
	if view_model.has("tooltip"):
		_button.tooltip_text = String(view_model["tooltip"])


func refresh(view_model: Dictionary) -> void:
	setup(view_model)


func clear() -> void:
	setup({"texture": null, "disabled": false, "visible": true})


func get_button() -> TextureButton:
	_bind_button()
	return _button


func get_view_model() -> Dictionary:
	return _view_model.duplicate(true)


func _bind_button() -> void:
	if is_instance_valid(_button):
		return
	if not button_path.is_empty():
		_button = get_node_or_null(button_path) as TextureButton
	if _button == null:
		_button = _find_texture_button(self)
	if _button == null:
		return
	if not _button.pressed.is_connected(_on_button_pressed):
		_button.pressed.connect(_on_button_pressed)
	if not _button.mouse_entered.is_connected(_on_pointer_entered):
		_button.mouse_entered.connect(_on_pointer_entered)
	if not _button.mouse_exited.is_connected(_on_pointer_exited):
		_button.mouse_exited.connect(_on_pointer_exited)


func _find_texture_button(node: Node) -> TextureButton:
	for child in node.get_children():
		if child is TextureButton:
			return child as TextureButton
		var nested := _find_texture_button(child)
		if nested != null:
			return nested
	return null


func _on_button_pressed() -> void:
	pressed.emit(self)


func _on_pointer_entered() -> void:
	pointer_entered.emit(self)


func _on_pointer_exited() -> void:
	pointer_exited.emit(self)
