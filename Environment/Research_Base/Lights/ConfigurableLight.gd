@tool
class_name ConfigurableLight
extends StaticBody3D

var _omniLightPoints : Array[OmniLight3D]

# Special Editor Variables
@export var lightColorMat: Material:
	set(value):
		lightColorMat = value
		
		for mesh: MeshInstance3D in find_children("*", "MeshInstance3D"):
			if mesh.get_surface_override_material_count() > 0: mesh.set_surface_override_material(1, lightColorMat)
@export_range(0.0, 5.0) var lightMultiplier := 1.0:
	set(value):
		lightMultiplier = value
		
		for omni in _omniLightPoints:
			omni.light_energy = 0.5 * lightMultiplier
@export_color_no_alpha var lightColor := Color.WHITE:
	set(value):
		lightColor = value
		for omni in _omniLightPoints:
			omni.light_color = lightColor

func _ready() -> void:
	for omni: OmniLight3D in find_children("*", "OmniLight3D"):
		_omniLightPoints.append(omni)


func turn_off() -> void:
	for omni in _omniLightPoints:
		omni.visible = false
func turn_on() -> void:
	for omni in _omniLightPoints:
		omni.visible = true
