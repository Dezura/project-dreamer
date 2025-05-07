class_name InventoryUI
extends Control

signal menu_toggled(state: bool)

var _menu_enabled := false:
	set = set_menu_enabled
var _item_boxes: Dictionary[String, InvItemBox]

@onready var _empty_message_label: Label = $ScrollContainer/Items/EmptyMessage
@onready var _items_container: VBoxContainer = $ScrollContainer/Items


#region Virtuals
func _ready() -> void:
	g.inventory_data.inventory_changed.connect(_on_inventory_data_change)
#endregion


func set_menu_enabled(value: bool) -> void:
	_menu_enabled = value
	self.visible = _menu_enabled
	
	menu_toggled.emit(_menu_enabled)


func toggle_menu_enabled() -> void:
	set_menu_enabled(not _menu_enabled)


func is_menu_enabled() -> bool:
	return _menu_enabled


func _on_inventory_data_change() -> void:
	@warning_ignore("untyped_declaration")
	var data = g.inventory_data.get_held_items()
	var excess_delete_boxes : Array[String] = _item_boxes.keys()
	@warning_ignore("untyped_declaration")
	for item_name in data:
		# Remove item from deletion list since it still exists in data
		excess_delete_boxes.erase(item_name)
		
		if !_item_boxes.keys().has(item_name):
			var new_inv_box : InvItemBox = preload("res://src/ui/_res/components/inv_item_box.tscn").instantiate()
			_item_boxes.get_or_add(item_name, new_inv_box)
			_items_container.add_child(new_inv_box)
			
			new_inv_box.item_data = g.inventory_data.item_database[item_name]
			new_inv_box.item_quantity = data[item_name]
		else:
			_item_boxes[item_name].item_quantity = data[item_name]
	
	# Delete item boxes not found inside inventory data anymore
	for item_name in excess_delete_boxes:
		_item_boxes[item_name].queue_free()
		_item_boxes.erase(item_name)
	
	_empty_message_label.visible = _item_boxes.is_empty()
