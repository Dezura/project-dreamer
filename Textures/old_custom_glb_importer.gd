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
	
	var modifiedScene: Node = generate_mesh_scene(scene)
	
	# Check if file is under a Models folder, auto prefabs will be made for files in this folder type
	var prefabPath: String = get_source_file()
	if prefabPath.split("/")[-2] == "Models":
		prefabPath = prefabPath.rsplit("/", true, 2)[0]
		prefabPath += "/" + get_source_file_name() + ".tscn"
		
		# Only create a new prefab if a current one doesn't exist
		if ResourceLoader.exists(prefabPath):
			print_rich("[color=green]     Found scene exists at \"" + prefabPath + "\", doing magic.")
		else:
			print_rich("[color=cyan]     No scene exists at \"" + prefabPath + "\", creating new file.")
			
			# Empty StaticBody3D as root for prefab
			var newPrefabRoot: Node3D = StaticBody3D.new()
			newPrefabRoot.name = get_source_file_name()
			
			match modifiedScene.get_class():
				"MeshInstance3D":
					var newMeshInstance: MeshInstance3D = modifiedScene.duplicate()
					newPrefabRoot.add_child(newMeshInstance)
					newMeshInstance.owner = newPrefabRoot
					newMeshInstance.name = "Mesh"
					
					newMeshInstance.create_trimesh_collision()
					var meshCollision: CollisionShape3D = newMeshInstance.get_child(0).get_child(0)
					newMeshInstance.get_child(0).remove_child(meshCollision)
					meshCollision.owner = null
					newPrefabRoot.add_child(meshCollision)
					meshCollision.owner = newPrefabRoot
					meshCollision.visible = false
					newMeshInstance.get_child(0).free()
				"Node3D":
					var modelNodesRoot: Node3D = modifiedScene.duplicate()
					# Remove unnecessary empty roots
					if modelNodesRoot.get_child_count() == 1 and modelNodesRoot.get_child(0).is_class("Node3D"):
						for child in modelNodesRoot.get_child(0).get_children():
							add_distant_child(child, newPrefabRoot)
					else:
						print_rich("[color=red]     Scene processing error, no new file will be generated.")
				# Default to this if can't recognize scene root
				_:
					print_rich("[color=red]     Scene processing error, no new file will be generated.")
			
			# Pack generated prefab scene and check if good to save
			var savedPrefab = PackedScene.new()
			var result = savedPrefab.pack(newPrefabRoot)
			if result == OK:
				# Save to file
				var error = ResourceSaver.save(savedPrefab, prefabPath)
				if error != OK:
					push_error(("An error occurred while saving the scene to disk."))
	else:
		print_rich("[color=red]     Glb not in Models folder... No prefab generation.")
	
	
	return modifiedScene

func generate_mesh_scene(scene) -> Object:
	match scene.get_class():
		"RigidBody3D":
			return scene
		"Node3D", _:
			# If only found single mesh
			if scene.get_child_count() == 1 and scene.get_child(0).get_child_count() == 0:
				var forsakenChild = scene.get_child(0)
				detach_as_new_root(forsakenChild)
				print_imported_as("Simple Mesh")
				forsakenChild.name = get_source_file_name()
				return forsakenChild
			# If found with staticbody collision enabled, limited flexibility rn since lazy
			#     Refactor later im so fucking tired
			elif scene.find_children("*", "StaticBody3D").size() == 1 and scene.get_child_count() == 1:
				var forsakenChild: Node = scene.find_children("*", "StaticBody3D")[0]
				var meshRoot: Node = scene.get_child(0)
				detach_as_new_root(meshRoot)
				detach_as_new_root(forsakenChild)
				
				forsakenChild.add_child(meshRoot)
				set_children_owner(forsakenChild, forsakenChild)
				
				forsakenChild.find_children("*", "CollisionShape3D")[0].visible = false
				rename_mesh_instances(forsakenChild)
				forsakenChild.name = get_source_file_name()
				print_imported_as("StaticBody3D Reroot")
				return forsakenChild
			# Catch case
			else:
				rename_mesh_instances(scene)
				scene.name = get_source_file_name()
				print_imported_as("Stock Standard")
				return scene
	return scene

func print_imported_as(context: String):
	print_rich("[color=green]     Imported '" + get_source_file_name(true) + "' as " + context)


func rename_mesh_instances(node: Node):
	if node.find_children("*", "MeshInstance3D").size() > 1: return
	for child in node.find_children("*", "MeshInstance3D"):
		child.name = "MeshInstance3D"


func get_source_file_name(includeExtension := false) -> String:
	if includeExtension: return get_source_file().split("/")[-1]
	else: return get_source_file().split("/")[-1].split(".")[0]


func detach_as_new_root(node: Node):
	var oldParent: Node = node.owner
	set_children_owner(node, node)
	oldParent.remove_child(node)
	node.owner = oldParent.owner


func set_children_owner(node, owner):
	for n in node.get_children():
		n.owner = owner
		set_children_owner(n, owner)

func add_distant_child(node, owner):
	if node.get_parent() != null:
		node.get_parent().remove_child(node)
	node.owner = null
	owner.add_child(node)
	node.owner = owner
	set_children_owner(node, owner)
