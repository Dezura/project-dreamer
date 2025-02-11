class_name ItemResource
extends Resource

@export_placeholder("Identifier") var identifer: String
@export_placeholder("Enter UI name here") var visualName: String
@export_multiline var description: String
@export_category(" ")
@export var stackable := false
@export var maxStackSize := 1

enum ItemType { KEY, CONSUMABLE, TOOL, LORE, MISC }
@export var type: ItemType

@export var mesh: Mesh
