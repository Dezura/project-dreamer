class_name BasicDoor
extends Interactable

var _is_opened : bool = false

func _on_interaction() -> void:
	super()
	
	open_door()

func open_door() -> void:
	prep_camera_position()
	
	g.gui_manager.hide_elements()
	g.player.immobile = true
	
	for mesh:MeshInstance3D in find_children('*', 'MeshInstance3D'):
		mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	await get_tree().create_timer(0.75).timeout
	$AnimationPlayer.play("start_cutscene")

func prep_camera_position() -> void:
	var dir = to_local(g.player.global_transform.origin).normalized()
	if (dir.x > 0):
		$"Camera Side Pivot".rotation_degrees.y = 0.0
	elif (dir.x < 0):
		$"Camera Side Pivot".rotation_degrees.y = 180.0
	
	$"Camera Side Pivot/Camera3D".global_position = g.player.get_node("Head/Camera").global_position
	$"Camera Side Pivot/Camera3D".global_rotation = g.player.get_node("Head/Camera").global_rotation
	$"Camera Side Pivot/Camera3D".current = true

# Chain logic based off finishing animations
# 	Player Interaction -> Start Cutscene -> Open Door -> Teleport -> Close Door
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "start_cutscene":
		_is_opened = true
		interactable = false
		
		$AnimationPlayer.play("door_open")
	
	if anim_name == "door_open":
		_is_opened = false
		interactable = true
		teleport_player()
		$"Camera Side Pivot/Camera3D".current = false
		
		$AnimationPlayer.play("door_close")

func teleport_player() -> void:
	# Find which side player is on
	var dir = to_local(g.player.global_transform.origin).normalized()
	
	# Set player position and rotation to opposite side
	if (dir.x > 0):
		g.player.position = position + Vector3(-1.5, 0, 0).rotated(Vector3.UP, rotation.y)
		g.player.get_node("Head").rotation_degrees = Vector3(0, 90, 0)+global_rotation_degrees
	elif (dir.x < 0):
		g.player.position = position + Vector3(1.5, 0, 0).rotated(Vector3.UP, rotation.y)
		g.player.get_node("Head").rotation_degrees = Vector3(0, -90, 0)+global_rotation_degrees
	
	# Reveal UI and player control again
	g.gui_manager.show_elements()
	g.player.get_node("GUI/BlackscreenCover/FadeAnimation").play("fade_out")
	
	g.player.immobile = false
