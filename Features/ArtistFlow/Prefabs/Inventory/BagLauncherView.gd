extends NinePatchRect
class_name BagLauncherView

signal bag_requested

@onready var bag_button: TextureButton = $Bag_Button
@onready var capacity_beans: Array[TextureRect] = [
	$AbilityBar/Bean1, $AbilityBar/Bean2, $AbilityBar/Bean3,
	$AbilityBar/Bean4, $AbilityBar/Bean5,
]


func _ready() -> void:
	bag_button.pressed.connect(func() -> void: bag_requested.emit())


func setup(view_model: Dictionary) -> void:
	set_capacity(int(view_model.get("used", 0)), int(view_model.get("capacity", capacity_beans.size())))


func refresh(view_model: Dictionary) -> void:
	setup(view_model)


func set_capacity(used: int, capacity: int = 5) -> void:
	for index in capacity_beans.size():
		capacity_beans[index].visible = index < mini(used, capacity)


func get_button() -> TextureButton:
	return bag_button
