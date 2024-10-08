extends Node3D

signal activated

var is_opened : bool = false
@onready var interactable : bool = true

func _on_activated() -> void:
	var dir = to_local(g.player.global_transform.origin).normalized()
	if (dir.x > 0):
		$"Camera Side Pivot".rotation_degrees.y = 0.0
	elif (dir.x < 0):
		$"Camera Side Pivot".rotation_degrees.y = 180.0
	
	$"Camera Side Pivot/Camera3D".global_position = g.player.get_node("Head/Camera").global_position
	$"Camera Side Pivot/Camera3D".global_rotation = g.player.get_node("Head/Camera").global_rotation
	$"Camera Side Pivot/Camera3D".current = true
	
	g.player.get_node("UserInterface").visible = false
	g.player.immobile = true
	
	await get_tree().create_timer(0.25).timeout
	$AnimationPlayer.play("drift_camera")

func _teleport_player() -> void:
	var dir = to_local(g.player.global_transform.origin).normalized()
	if (dir.x > 0):
		g.player.position = position + Vector3(-1.5, 0, 0).rotated(Vector3.UP, rotation.y)
		g.player.get_node("Head").rotation_degrees = Vector3(0, 90, 0)+global_rotation_degrees
	elif (dir.x < 0):
		g.player.position = position + Vector3(1.5, 0, 0).rotated(Vector3.UP, rotation.y)
		g.player.get_node("Head").rotation_degrees = Vector3(0, -90, 0)+global_rotation_degrees
	g.player.get_node("UserInterface").visible = true
	g.player.immobile = false
	g.player.get_node("UserInterface/Fade/FadeAnimation").play("fade_out")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "door_open":
		if (is_opened):
			$AnimationPlayer.play("door_close")
			is_opened = false
			interactable = true
		$"Camera Side Pivot/Camera3D".current = false
	if anim_name == "drift_camera":
		if !is_opened:
			$AnimationPlayer.play("door_open")
			is_opened = true
			interactable = false
