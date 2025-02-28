class_name CutsceneDoor
extends Door

@onready var _door_knob : MouseClickable = $big_side/knob/Area3D

func _ready() -> void:
	super()
	_door_knob.mouse_entered.connect(_on_knob_mouse_event.bind(true))
	_door_knob.mouse_exited.connect(_on_knob_mouse_event.bind(false))

func _on_knob_mouse_event(mouse_entered = true):
	if !_door_knob.clickable: return
	if mouse_entered:
		set_mesh_highlight($big_side/knob, HighlightState.PASSIVE_RANGE)
	else:
		set_mesh_highlight($big_side/knob, HighlightState.NEUTRAL)

func _on_door_open_interaction(initial_room: Room, target_room: Room) -> void:
	interaction_disabled = true
	
	# Load new room before starting cutscene
	target_room.load_area()
	
	# Start camera from player POV
	_prep_camera_position()
	
	# Disable player for cutscene
	g.gui_manager.hide_elements()
	g.gui_manager.hide_interaction()
	g.player.clear_selected_interactable()
	g.player.immobile = true
	g.player.interaction_disabled = true
	
	await get_tree().create_timer(0.75).timeout
	# Go in front of door
	$CutsceneAnimation.play("pan_in_front_of_door")
	
	await g.wait_for_animation_end($CutsceneAnimation, "pan_in_front_of_door")
	
	# Wait for player to click on knob
	g.gui_manager.show_mouse()
	_door_knob.clickable = true
	await $big_side/knob/Area3D.clicked
	set_mesh_highlight($big_side/knob, HighlightState.NEUTRAL)
	g.gui_manager.hide_mouse()
	_door_knob.clickable = false
	
	# Move through the door
	$CutsceneAnimation.play("enter_through_door")
	
	# Teleport into room and close door behind player
	await g.wait_for_animation_end($CutsceneAnimation, "enter_through_door")
	_teleport_player()
	g.player._on_entered_room(target_room)
	
	# Reveal UI and player control again
	g.gui_manager.show_elements()
	g.player.get_node("GUI/BlackscreenCover/FadeAnimation").play("fade_out")
	g.player.immobile = false
	g.player.interaction_disabled = false
	# Set camera back to player
	$"Camera Side Pivot/Camera3D".current = false
	
	# Start door close after player is in control
	await get_tree().create_timer(0.5).timeout
	close_door()
	
	# Unload old room since door has fully closed
	await g.wait_for_animation_end($DoorAnimations, "door_close")
	initial_room.unload_area()

func _prep_camera_position() -> void:
	var dir = to_local(g.player.global_transform.origin).normalized()
	if (dir.x > 0):
		$"Camera Side Pivot".rotation_degrees.y = 0.0
	elif (dir.x < 0):
		$"Camera Side Pivot".rotation_degrees.y = 180.0
	
	$"Camera Side Pivot/Camera3D".global_position = g.player.get_node("Head/Camera").global_position
	$"Camera Side Pivot/Camera3D".global_rotation = g.player.get_node("Head/Camera").global_rotation
	$"Camera Side Pivot/Camera3D".current = true

func _teleport_player() -> void:
	# Find which side player is on
	var dir = to_local(g.player.global_transform.origin).normalized()
	
	# Set player position and rotation to opposite side
	if (dir.x > 0):
		g.player.position = position + Vector3(-1.5, 0, 0).rotated(Vector3.UP, rotation.y)
		g.player.get_node("Head").rotation_degrees = Vector3(0, 90, 0)+global_rotation_degrees
	elif (dir.x < 0):
		g.player.position = position + Vector3(1.5, 0, 0).rotated(Vector3.UP, rotation.y)
		g.player.get_node("Head").rotation_degrees = Vector3(0, -90, 0)+global_rotation_degrees
