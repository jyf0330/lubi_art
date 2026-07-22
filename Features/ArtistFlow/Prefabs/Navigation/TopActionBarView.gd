extends NinePatchRect
class_name TopActionBarView

signal back_requested
signal sell_requested

@onready var back_button: TextureButton = $Top_Shop/Shop_BackButton
@onready var sell_button: Button = $Top_Sell


func _ready() -> void:
	back_button.pressed.connect(func() -> void: back_requested.emit())
	sell_button.pressed.connect(func() -> void: sell_requested.emit())


func setup(view_model: Dictionary) -> void:
	back_button.visible = bool(view_model.get("back_visible", true))
	sell_button.visible = bool(view_model.get("sell_visible", true))


func refresh(view_model: Dictionary) -> void:
	setup(view_model)


func get_back_button() -> TextureButton:
	return back_button


func get_sell_button() -> Button:
	return sell_button
