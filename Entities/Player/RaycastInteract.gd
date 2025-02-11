extends RayCast3D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var interactionObject: Interactable = null
	if get_collider() != null:
		if get_collider() is Interactable:
			interactionObject = get_collider()
		elif "master" in get_collider() and get_collider().master != null:
			interactionObject = get_collider().master
	if interactionObject != null and interactionObject.interactable:
		g.gui_manager.set_interaction_title(interactionObject.title)
		g.gui_manager.set_interaction_choice(interactionObject.interactionText)
		g.gui_manager.show_interaction()
		
		if Input.is_action_just_pressed("Interact") and !g.player.immobile:
			interactionObject.emit_signal("activated")
	else:
		g.gui_manager.hide_interaction()
