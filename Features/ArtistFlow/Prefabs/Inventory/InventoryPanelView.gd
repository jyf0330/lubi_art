extends GridContainer
class_name InventoryPanelView


func setup(view_model: Dictionary) -> void:
	var items := Array(view_model.get("items", []))
	var slots := get_slots()
	for index in slots.size():
		if slots[index].has_method("setup"):
			slots[index].call("setup", Dictionary(items[index]) if index < items.size() else {})


func refresh(view_model: Dictionary) -> void:
	setup(view_model)


func get_slots() -> Array[Control]:
	var result: Array[Control] = []
	for child in get_children():
		if child is Control:
			result.append(child as Control)
	return result
