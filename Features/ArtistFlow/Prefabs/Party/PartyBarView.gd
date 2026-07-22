extends NinePatchRect
class_name PartyBarView

@onready var slots_container: GridContainer = $Party_Container


func setup(view_model: Dictionary) -> void:
	var items := Array(view_model.get("items", []))
	var slots := get_slots()
	for index in slots.size():
		var item := Dictionary(items[index]) if index < items.size() else {}
		if slots[index].has_method("setup"):
			slots[index].call("setup", item)


func refresh(view_model: Dictionary) -> void:
	setup(view_model)


func get_slots_container() -> GridContainer:
	return slots_container


func get_slots() -> Array[Control]:
	var result: Array[Control] = []
	for child in slots_container.get_children():
		if child is Control:
			result.append(child as Control)
	return result
