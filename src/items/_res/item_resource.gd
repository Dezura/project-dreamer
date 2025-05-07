class_name ItemResource
extends Resource

enum ItemType { KEY, CONSUMABLE, TOOL, LORE, MISC }

@export_placeholder("Identifier") var identifer: String
@export_placeholder("Enter UI name here") var visual_name: String
@export_multiline var description: String
@export_category(" ")
@export var stackable := false
@export var maxStackSize: int = 1
@export var type: ItemType
@export var mesh: Mesh
