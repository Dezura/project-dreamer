class_name InventoryData
extends Node

signal inventory_changed

@export var item_database: Dictionary[String, ItemResource]

var _current_inventory: Array


func add_item(item_name: String, quantity: int = 1) -> void:
	@warning_ignore("untyped_declaration")
	for item in _current_inventory:
		if item["item_name"] == item_name:
			item["quantity"] += quantity
			
			g.debug_print(" %s" % _current_inventory, g.TextColor.PURPLE)
			emit_signal("inventory_changed")
			return
	
	if item_database.has(item_name): 
		_current_inventory.append({"item_name": item_name, "quantity": quantity})
		
		g.debug_print(" %s" % _current_inventory, g.TextColor.PURPLE)
		emit_signal("inventory_changed")
	else: 
		g.debug_print(' Item key "%s" not found in database' % item_name)


func try_consume_item(item_name: String, quantity: int = 1) -> bool:
	@warning_ignore("untyped_declaration")
	for item in _current_inventory:
		if item["item_name"] == item_name and item["quantity"] >= quantity:
			item["quantity"] -= quantity
			
			if item["quantity"] <= 0: 
				_current_inventory.erase(item)
			
			g.debug_print(" %s" % _current_inventory, g.TextColor.PURPLE)
			emit_signal("inventory_changed")
			return true
	return false


func has_item(item_name: String, quantity: int = 1) -> bool:
	@warning_ignore("untyped_declaration")
	for item in _current_inventory:
		if item["item_name"] == item_name and item["quantity"] >= quantity:
			return true
	return false


func get_held_items() -> Dictionary[String, int]: # Item name, quantity
	var return_list: Dictionary[String, int]
	@warning_ignore("untyped_declaration")
	for item in _current_inventory:
		return_list[item["item_name"]] = item["quantity"]
	return return_list
