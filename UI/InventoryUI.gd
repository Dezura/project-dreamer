class_name InventoryUI
extends Control

var _item_boxes : Dictionary[String, InvItemBox]

func _ready() -> void:
	menu_toggled.connect(_on_inventory_menu_toggled)
	
	g.inventory_data.inventory_changed.connect(_on_inventory_data_change)

func _on_inventory_data_change():
	var data = g.inventory_data.get_held_items()
	var excess_delete_boxes : Array[String] = _item_boxes.keys()
	for item_name in data:
		# Remove item from deletion list since it still exists in data
		excess_delete_boxes.erase(item_name)
		
		if !_item_boxes.keys().has(item_name):
			var new_inv_box : InvItemBox = preload("res://UI/Components/InvItemBox.tscn").instantiate()
			_item_boxes.get_or_add(item_name, new_inv_box)
			$ScrollContainer/Items.add_child(new_inv_box)
			
			new_inv_box.item_data = g.inventory_data.item_database[item_name]
			new_inv_box.item_quantity = data[item_name]
		else:
			_item_boxes[item_name].item_quantity = data[item_name]
	
	# Delete item boxes not found inside inventory data anymore
	for item_name in excess_delete_boxes:
		_item_boxes[item_name].queue_free()
		_item_boxes.erase(item_name)
	
	$ScrollContainer/Items/EmptyMessage.visible = _item_boxes.is_empty()

#region Core
signal menu_toggled(state : bool)
var is_menu_enabled : bool = false

func toggle_menu():
	menu_toggled.emit(!is_menu_enabled)
func set_menu(state):
	menu_toggled.emit(state)

func _on_inventory_menu_toggled(to_state : bool):
	is_menu_enabled = to_state
	self.visible = is_menu_enabled
#endregion
