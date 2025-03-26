extends Node

enum CollisionLayers{
	MAP_COLLISSION = 1 << 0,
	INTERACTABLE = 1 << 1,
	L3 = 1 << 2,
	L4 = 1 << 3,
	L5 = 1 << 4,
	L6 = 1 << 5,
	L7 = 1 << 6,
	MOUSE_CLICKABLE = 1 << 7,
	PLAYER_COLLISION = 1 << 8,
	L10 = 1 << 9,
	L11 = 1 << 10,
	L12 = 1 << 11,
	L13 = 1 << 12,
	L14 = 1 << 13,
	L15 = 1 << 14,
	L16 = 1 << 15,
}

enum TextColor{
	RED,
	GREEN,
	BLUE,
	YELLOW,
	CYAN,
	MAGENTA,
	WHITE,
	BLACK,
	GRAY,
	ORANGE,
	PINK,
	PURPLE,
}

var player: Player
var gui: GUI
var inventory_data: InventoryData


#region Virtuals
func _ready() -> void:
	player = get_node("/root").find_child("Player", true, false)
	gui = get_node("/root").find_child("GUI", true, false)
	inventory_data = get_node("/root").find_child("InventoryData", true, false)
#endregion


@warning_ignore("untyped_declaration")
func debug_print(text, color_enum: TextColor = TextColor.WHITE) -> void:
	var color_string: String
	color_string = str(TextColor.keys()[color_enum]).to_lower()
	
	print_rich("[color=%s]%s" % [color_string, text])


func wait_for_animation_end(anim_player: AnimationPlayer, anim_name: String) -> void:
	while anim_player.current_animation != anim_name:
		await anim_player.animation_changed
	await anim_player.animation_finished
