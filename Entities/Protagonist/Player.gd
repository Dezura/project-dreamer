class_name Player
extends MovementControls

var interaction_disabled : bool = false
var current_room : Room
var _selected_interactable : Interactable

func _process(delta: float) -> void:
	super(delta)
	
	# Update raycast to check if an interactable should be highlighted
	if Input.is_action_just_pressed("ui_cancel"):
		match Input.mouse_mode:
			Input.MOUSE_MODE_CAPTURED:
				g.gui_manager.show_mouse()
			Input.MOUSE_MODE_VISIBLE:
				g.gui_manager.hide_mouse()
	
	if !interaction_disabled: 
		var interactable := query_interactable()
		# Run for every frame interactable is selected
		if interactable != null and !interactable.interaction_disabled:
			# If interactable is newly selected
			if interactable != _selected_interactable:
				_selected_interactable = interactable
				interactable.selected.emit(true)
				# Set GUI text to match current interactable
				g.gui_manager.set_interaction_title(interactable.interaction_title)
				g.gui_manager.set_interaction_choice(interactable.interaction_text)
				g.gui_manager.show_interaction()
			
			# Otherwise keep checking for input every frame
			if Input.is_action_just_pressed("Interact"):
				interactable.interaction_pressed.emit()
		
		# If last interactable is not currently selected anymore
		elif _selected_interactable != null:
			clear_selected_interactable()

func query_interactable() -> Interactable:
	var cast_object = $Head/InteractionCaster.get_collider()
	# Return if raycast reached no objects
	if cast_object == null:
		return
	
	# Open interaction GUI and select the object if it's interactable
	if cast_object is Interactable:
		return cast_object as Interactable
	# If cast_object itself isn't interactable, check if it's under the tree of an actual interactable prefab
	elif cast_object.owner is Interactable and cast_object.get_collision_layer_value(g.CollisionLayers.INTERACTABLE):
		return cast_object.owner as Interactable
	return null

func clear_selected_interactable():
	_selected_interactable.selected.emit(false)
	g.gui_manager.hide_interaction()
	_selected_interactable = null

func _on_entered_room(newRoom : Room):
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
