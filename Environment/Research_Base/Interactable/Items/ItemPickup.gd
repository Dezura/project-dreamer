class_name ItemPickup
extends Interactable

@export var itemData: ItemResource
@export var respawnable := false

func _on_interaction() -> void:
	super()
	
	print_rich("[color=orange] Picked up item!")
	g.inventory.add_item(itemData.identifer)
	disable_pickup()
	if respawnable:
		await get_tree().create_timer(2.75).timeout
		respawn_pickup()

func disable_pickup():
	for collisionShape: CollisionShape3D in find_children("*", "CollisionShape3D"):
		print_rich("[color=red] Disabled " + collisionShape.name)
		collisionShape.disabled = true
	
	hide()

func respawn_pickup():
	print_rich("[color=yellow] Respawned an item!")
	for collisionShape: CollisionShape3D in find_children("*", "CollisionShape3D"):
		print_rich("[color=green] Enabled " + collisionShape.name)
		collisionShape.disabled = false
	
	show()
