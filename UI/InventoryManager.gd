class_name InventoryManager
extends Control

@export var itemDatabase: Dictionary[String, ItemResource]

var _inventory: Array

signal inventory_changed


func _process(delta: float):
	$TempItemDisplay.text = str(_inventory)


func add_item(itemName: String, quantity: int = 1):
	for item in _inventory:
		if item["itemName"] == itemName:
			item["quantity"] += quantity
			print_rich("[color=purple] " + str(_inventory))
			emit_signal("inventory_changed")
			return
	if itemDatabase.has(itemName): 
		_inventory.append({"itemName": itemName, "quantity": quantity})
		emit_signal("inventory_changed")
	else: print_rich("[color=red] Item key \"" + itemName + "\" not found in database")


func try_consume_item(itemName: String, quantity: int = 1) -> bool:
	for item in _inventory:
		if item["itemName"] == itemName and item["quantity"] >= quantity:
			item["quantity"] -= quantity
			print_rich("[color=purple] " + str(_inventory))
			if item["quantity"] <= 0: _inventory.erase(item)
			emit_signal("inventory_changed")
			return true
	return false

func has_item(itemName: String, quantity: int = 1) -> bool:
	for item in _inventory:
		if item["itemName"] == itemName and item["quantity"] >= quantity:
			return true
	return false
