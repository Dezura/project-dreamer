@tool
extends StaticBody3D

var _storedAlbedoColor: Color
@export var lightColorMat: Material:
	set(value):
		lightColorMat = value
		
		_set_light_properties()
		for mesh: MeshInstance3D in find_children("*", "MeshInstance3D"):
			if mesh.get_surface_override_material_count() > 0: mesh.set_surface_override_material(1, lightColorMat)

@export_range(0.0, 5.0) var lightMultiplier := 1.0:
	set(value):
		lightMultiplier = value
		
		for light: OmniLight3D in find_children("*", "OmniLight3D"):
			light.light_energy = 0.3 * lightMultiplier

func _set_light_properties():
	if lightColorMat != null: _storedAlbedoColor = lightColorMat.albedo_color
	else: _storedAlbedoColor = Color.WHITE
	
	for light: Light3D in find_children("*", "Light3D"):
		light.light_color = _storedAlbedoColor

func _process(delta) -> void:
	if Engine.is_editor_hint() and lightColorMat.albedo_color != _storedAlbedoColor:
		_set_light_properties()
