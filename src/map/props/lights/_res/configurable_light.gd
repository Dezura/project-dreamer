@tool
class_name ConfigurableLight
extends StaticBody3D

@export var light_color_mat: Material:
	set = set_light_color_mat
@export_range(0.0, 5.0) var light_multiplier: float = 1.0:
	set = set_light_multiplier
@export_color_no_alpha var light_color := Color.WHITE:
	set = set_light_color

var _omni_light_points: Array[OmniLight3D]

#region Virtuals
func _ready() -> void:
	for omni: OmniLight3D in find_children("*", "OmniLight3D"):
		_omni_light_points.append(omni)
		omni.light_color = light_color
		omni.light_energy = 0.8 * light_multiplier
#endregion


func set_light_color_mat(value: Material) -> void:
	light_color_mat = value
	
	for mesh: MeshInstance3D in find_children("*", "MeshInstance3D"):
		if mesh.get_surface_override_material_count() > 0: mesh.set_surface_override_material(1, light_color_mat)


func set_light_multiplier(value: float) -> void:
	light_multiplier = value
	
	for omni in _omni_light_points:
		omni.light_energy = 0.8 * light_multiplier


func set_light_color(value: Color) -> void:
	light_color = value
	for omni in _omni_light_points:
		omni.light_color = light_color


func turn_on() -> void:
	for omni in _omni_light_points:
		omni.visible = true


func turn_off() -> void:
	for omni in _omni_light_points:
		omni.visible = false
