class_name CutsceneDoor
extends Door

@onready var _clickable_knob: MouseClickable = $big_side/knob/Area3D
@onready var _door_knob_mesh: MeshInstance3D = $big_side/knob
@onready var _cutscene_animation: AnimationPlayer = $CutsceneAnimation
@onready var _cutscene_camera: Camera3D = $"Camera Side Pivot/Camera3D"
@onready var _cutscene_camera_pivot: Node3D = $"Camera Side Pivot"


#region Virtuals
func _ready() -> void:
	super()
	_clickable_knob.mouse_entered.connect(_on_knob_mouse_event.bind(true))
	_clickable_knob.mouse_exited.connect(_on_knob_mouse_event.bind(false))


func _door_open_interaction(initial_room: Room, target_room: Room) -> void:
	interaction_disabled = true
	
	# Load new room before starting cutscene
	target_room.load_area()
	
	# Start camera from player POV
	_prep_camera_position()
	
	# Disable player for cutscene
	g.gui.turn_off_hud()
	g.player.clear_selected_interactable()
	g.player.immobile = true
	g.player.interaction_disabled = true
	
	await get_tree().create_timer(0.75).timeout
	# Go in front of door
	_cutscene_animation.play("pan_in_front_of_door")
	
	await g.wait_for_animation_end(_cutscene_animation, "pan_in_front_of_door")
	
	# Wait for player to click on knob
	g.gui.cursor_ui.show_mouse()
	_clickable_knob.clickable = true
	await _clickable_knob.clicked
	set_mesh_highlight(_door_knob_mesh, HighlightState.NEUTRAL)
	g.gui.cursor_ui.hide_mouse()
	_clickable_knob.clickable = false
	
	# Move through the door
	_cutscene_animation.play("enter_through_door")
	
	# Teleport into room and close door behind player
	await g.wait_for_animation_end(_cutscene_animation, "enter_through_door")
	_teleport_player()
	g.player._on_entered_room(target_room)
	
	# Reveal UI and player control again
	g.gui.turn_on_hud()
	(g.gui.get_node("BlackscreenCover") as ColorRect).color = Color(0, 0, 0, 1)
	(g.gui.get_node("BlackscreenCover/FadeAnimation") as AnimationPlayer).play("fade_out")
	
	g.player.immobile = false
	g.player.interaction_disabled = false
	# Set camera back to player
	_cutscene_camera.current = false
	# Start door close after player is in control
	await get_tree().create_timer(0.5).timeout
	close_door()
	
	# Unload old room since door has fully closed
	await g.wait_for_animation_end(_door_animations, "door_close")
	initial_room.unload_area()
#endregion


func _prep_camera_position() -> void:
	var dir:Vector3 = to_local(g.player.global_transform.origin).normalized()
	if (dir.x > 0):
		_cutscene_camera_pivot.rotation_degrees.y = 0.0
	elif (dir.x < 0):
		_cutscene_camera_pivot.rotation_degrees.y = 180.0
	
	_cutscene_camera.global_position = (g.player.get_node("Head/Camera") as Camera3D).global_position
	_cutscene_camera.global_rotation = (g.player.get_node("Head/Camera") as Camera3D).global_rotation
	_cutscene_camera.current = true


func _teleport_player() -> void:
	# Find which side player is on
	var dir: Vector3 = to_local(g.player.global_transform.origin).normalized()
	
	# Set player position and rotation to opposite side
	if (dir.x > 0):
		g.player.position = position + Vector3(-1.5, 0, 0).rotated(Vector3.UP, rotation.y)
		(g.player.get_node("Head") as Node3D).rotation_degrees = Vector3(0, 90, 0) + global_rotation_degrees
	elif (dir.x < 0):
		g.player.position = position + Vector3(1.5, 0, 0).rotated(Vector3.UP, rotation.y)
		(g.player.get_node("Head") as Node3D).rotation_degrees = Vector3(0, -90, 0) + global_rotation_degrees


func _on_knob_mouse_event(mouse_entered := true) -> void:
	if !_clickable_knob.clickable: 
		return
	if mouse_entered:
		set_mesh_highlight(_door_knob_mesh, HighlightState.PASSIVE_RANGE)
	else:
		set_mesh_highlight(_door_knob_mesh, HighlightState.NEUTRAL)
