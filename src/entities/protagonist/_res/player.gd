class_name Player
extends MovementControls

var interaction_disabled := false
var current_room: Room
var _selected_interactable: Interactable

@onready var _interaction_caster: RayCast3D = $Head/InteractionCaster


#region Virtuals
func _process(delta: float) -> void:
	super(delta)
	
	# Pretty much just debug code
	if Input.is_action_just_pressed("ui_cancel") and !g.gui.inventory_ui.is_menu_enabled():
		match Input.mouse_mode:
			Input.MOUSE_MODE_CAPTURED:
				g.gui.cursor_ui.show_mouse()
			Input.MOUSE_MODE_VISIBLE:
				g.gui.cursor_ui.hide_mouse()
	
	if Input.is_action_just_pressed("Open Inventory") and (!interaction_disabled or g.gui.inventory_ui.is_menu_enabled()):
		g.gui.inventory_ui.toggle_menu_enabled()
		
		# Disable control if inventory is open
		immobile = g.gui.inventory_ui.is_menu_enabled()
		interaction_disabled = g.gui.inventory_ui.is_menu_enabled()
	
	# Update raycast to check if an interactable should be highlighted
	if not interaction_disabled: 
		var interactable_object: Interactable = query_interactable()
		# Run for every frame interactable is selected
		if interactable_object != null and not interactable_object.interaction_disabled:
			# If interactable is newly selected
			if interactable_object != _selected_interactable:
				_selected_interactable = interactable_object
				interactable_object.selected_changed.emit(true)
				# Set GUI text to match current interactable
				g.gui.interaction_ui.set_interaction_title(interactable_object.interaction_title)
				g.gui.interaction_ui.set_interaction_choice(interactable_object.interaction_text)
				g.gui.interaction_ui.set_menu_enabled(true)
			
			# Otherwise keep checking for input every frame
			if Input.is_action_just_pressed("Interact"):
				interactable_object.interaction_pressed.emit()
		
		# If last interactable is not currently selected anymore
		elif _selected_interactable != null:
			clear_selected_interactable()
#endregion


func query_interactable() -> Interactable:
	var cast_object: Node3D = _interaction_caster.get_collider()
	# Return if raycast reached no objects
	if not cast_object:
		return
	
	# Open interaction GUI and select the object if it's interactable
	if cast_object is Interactable:
		return cast_object as Interactable
	# If cast_object itself isn't interactable, check if it's under the tree of an actual interactable prefab
	elif cast_object.owner is Interactable and cast_object is CollisionObject3D:
		if (cast_object as CollisionObject3D).get_collision_layer_value(g.CollisionLayers.INTERACTABLE):
			return cast_object.owner as Interactable
	return null


func clear_selected_interactable() -> void:
	_selected_interactable.selected_changed.emit(false)
	g.gui.interaction_ui.set_menu_enabled(false)
	_selected_interactable = null


func _on_entered_room(newRoom : Room) -> void:
	if current_room == newRoom: return
	
	# Set current to new room
	g.debug_print("Entered room '%s' [%s]" % [newRoom.room_name, newRoom.name], g.TextColor.CYAN)
	current_room = newRoom
	
	# Fix interaction titles on each door to lead into connected rooms
	for door in current_room.attached_doors:
		# If it's a cutscene door
		if door as CutsceneDoor != null:
			# Then set the interaction title to opposite room
			door.interaction_title = door.get_flipped_room(current_room).room_name
