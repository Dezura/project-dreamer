@tool
class_name ConfigurableLight
extends StaticBody3D

var _omni_light_points : Array[OmniLight3D]

# Special Editor Variables
@export var light_color_mat: Material:
	set(value):
		light_color_mat = value
		
		for mesh: MeshInstance3D in find_children("*", "MeshInstance3D"):
			if mesh.get_surface_override_material_count() > 0: mesh.set_surface_override_material(1, light_color_mat)
@export_range(0.0, 5.0) var light_multiplier := 1.0:
	set(value):
		light_multiplier = value
		
		for omni in _omni_light_points:
			omni.light_energy = 0.8 * light_multiplier
@export_color_no_alpha var light_color := Color.WHITE:
	set(value):
		light_color = value
		for omni in _omni_light_points:
			omni.light_color = light_color

func _ready() -> void:
	for omni: OmniLight3D in find_children("*", "OmniLight3D"):
		_omni_light_points.append(omni)
		omni.light_color = light_color
		omni.light_energy = 0.8 * light_multiplier


func turn_off() -> void:
	for omni in _omni_light_points:
		omni.visible = false
func turn_on() -> void:
	for omni in _omni_light_points:
		omni.visible = true
