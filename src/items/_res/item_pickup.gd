class_name ItemPickup
extends Interactable

@export var item_data: ItemResource
@export var respawnable := false


func disable_pickup() -> void:
	for collision_shape: CollisionShape3D in find_children("*", "CollisionShape3D"):
		g.debug_print(" Disabled %s" % collision_shape.name, g.TextColor.RED)
		collision_shape.disabled = true
	
	self.hide()


func respawn_pickup() -> void:
	g.debug_print(" Respawned an item!", g.TextColor.ORANGE)
	for collision_shape: CollisionShape3D in find_children("*", "CollisionShape3D"):
		g.debug_print(" Enabled %s" % collision_shape.name, g.TextColor.GREEN)
		collision_shape.disabled = false
	
	self.show()


func _on_interaction_pressed() -> void:
	super()
	
	g.debug_print(" Picked up item!", g.TextColor.ORANGE)
	g.inventory_data.add_item(item_data.identifer)
	disable_pickup()
	if respawnable:
		await get_tree().create_timer(2.75).timeout
		respawn_pickup()
