@tool
extends EditorScenePostImport


func _post_import(scene) -> Object:
	for child:MeshInstance3D in scene.find_children("*", "MeshInstance3D"):
		for i in child.mesh.get_surface_count():
			var materialName: String = child.mesh.surface_get_material(i).resource_name
			if ResourceLoader.exists("res://Textures/" + materialName + ".tres"):
				print_rich("[color=yellow] Existing material found for '" + materialName + "'... Swapping")
				var matchedMaterial: Material = load("res://Textures/" + materialName + ".tres")
				child.mesh.surface_set_material(i, matchedMaterial)
			else:
				print_rich("[color=red] No existing material under '" + materialName + "' in ./Textures... Leaving field unchanged")
	
	return scene
