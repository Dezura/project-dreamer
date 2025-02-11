extends Node

var player : Node3D
var gui_manager : GUI
var inventory : InventoryManager

func _ready() -> void:
	player = get_node("/root").find_child("Player", true, false)
	gui_manager = get_node("/root").find_child("GUI", true, false)
	inventory = get_node("/root").find_child("Inventory", true, false)
