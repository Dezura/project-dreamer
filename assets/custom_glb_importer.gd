@tool
extends EditorScenePostImport

# Only use this as a temp option for old GLBs. 
#   Remove deprecated names from list once no longer needed after replacing old GLBs
const DEPRECATED_MATERIAL_RENAME: Dictionary[String, String] = { # Dict[deprecated_name] = modern_name
	"Protagonist_mat": "protagonist",
	"Corridor": "lrs_interior",
	"Corridor Deco": "props_1",
	"Minimal UV Tech": "uv_basic_interior",
	"Corridor Deco Light": "dynamic_light",
	"Emissive_Light": "dynamic_light",
}
const DEBUG_MODE := false


func _post_import(scene: Node) -> Object:
	if not get_source_file().split('/')[2] == "src":
		print_rich("[color=red] File placed outside of 'res://src'... Skipping (%s)" % get_source_file())
		return scene
	
	var mesh_instances := scene.find_children("*", "MeshInstance3D")
	
	for node: MeshInstance3D in mesh_instances: # Fix and replace materials in each mesh
		fix_import_materials(node)
		
		# Get res path
		var mesh_data_name: String
		if mesh_instances.size() == 1:
			mesh_data_name = get_source_file().get_file().split('.')[0]
			node.mesh.resource_name = mesh_data_name
		else:
			node.mesh.resource_name = node.name.to_snake_case()
			mesh_data_name = node.mesh.resource_name
		var res_save_file_path: String = get_source_file_directory() + '/' + mesh_data_name + ".mesh"
		
		# Save to file
		var status: int = ResourceSaver.save(node.mesh, res_save_file_path, ResourceSaver.FLAG_REPLACE_SUBRESOURCE_PATHS)
		if DEBUG_MODE: print(error_string(status))
		if status == OK:
			node.mesh.take_over_path(res_save_file_path)
			if mesh_instances.size() == 1:
				print_rich("[color=cyan]Saved single mesh resource '%s.mesh' at path '%s' !" % [mesh_data_name, get_source_file_directory()])
			else:
				print_rich("[color=cyan]Saved multi mesh resource as derivative '%s.mesh' at path '%s'!" % [mesh_data_name, get_source_file_directory()])
		else:
			print_rich("[color=red] Error while saving mesh (%s)" % error_string(status))
	return scene


func fix_import_materials(node: MeshInstance3D) -> void:
	for material_num in node.mesh.get_surface_count():
		# Fetch material name and fix if deprecated
		var material_name: String = node.mesh.surface_get_material(material_num).resource_name
		if material_name in DEPRECATED_MATERIAL_RENAME.keys():
			var modern_name: String = DEPRECATED_MATERIAL_RENAME[material_name]
			# If material name in data is deprecated, run logic with new modern name instead
			print_rich("[color=orange] Deprecated material name '%s'... Querying for '%s' instead" % [material_name, modern_name])
			material_name = modern_name
		
		# FYI, Folder roots means a folder containing _res, not the _res folder itself
		var dir: DirAccess = DirAccess.open(get_source_file_directory())
		assert(dir != null)
		iterate_out_of_res(dir)
		
		if DEBUG_MODE: ("Checking root folders... ")
		# Iterate through each root folder to find material file
		var found_path: String = "NO PATH"
		while get_directory_name(dir.get_current_dir()) != "src" and dir.get_current_dir().contains("src"):
			if DEBUG_MODE: print(" %s <-" % dir.get_current_dir())
			
			if dir.file_exists(material_name + ".material"): # Material found in root, break
				found_path = dir.get_current_dir() + '/' + material_name + ".material"
				break
			
			if dir.dir_exists("_res"): # _res exists in root, search _res
				dir.change_dir("./_res")
				var search_result_path: String = recursive_search_folder_for_file(material_name + ".material", dir.get_current_dir())
				
				if search_result_path != "NO PATH": # Material found under _res or subfolder, break
					found_path = search_result_path
					break
				
				iterate_out_of_res(dir) # Exit current _res after nothing found
			
			dir.change_dir("../") # Check next root folder
		# Check commons folder as last resort
		if found_path == "NO PATH":
			if DEBUG_MODE: print(" %s <-" % "res://src/common")
			found_path = recursive_search_folder_for_file(material_name + ".material", "res://src/common")
		
		
		if found_path != "NO PATH":
			if (DEBUG_MODE): print_rich("[color=yellow] Existing material found at '%s'... Swapping" % found_path)
			var matched_material: Material = load(found_path)
			
			node.mesh.surface_set_material(material_num, matched_material)
		else:
			print_rich("[color=red] No existing material for '%s' found. Leaving field unchanged" % material_name)


func get_directory_name(path: String) -> String:
	return path.rsplit('/')[-1]


func get_source_file_directory() -> String:
	return get_source_file().rsplit('/', true, 1)[0]


# You could think of this function as a way to iterate back to the "root" folder containing the _res
func iterate_out_of_res(dir: DirAccess) -> void:
	while dir.get_current_dir().contains("_res"):
		dir.change_dir("../")


func recursive_search_folder_for_file(file_name: String, dir_path: String) -> String:
	var dir: DirAccess = DirAccess.open(dir_path)
	
	if dir.file_exists(file_name):
		return dir.get_current_dir() + '/' + file_name
	
	for subfolder_name in dir.get_directories():
		dir.change_dir(subfolder_name)
		var search_path_result: String = recursive_search_folder_for_file(file_name, dir.get_current_dir())
		if search_path_result != "NOT FOUND":
			return search_path_result
		dir.change_dir("../")
	
	return "NO PATH"
