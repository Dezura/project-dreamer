extends Node

var player : Player
var gui : GUI
var inventory_data : InventoryData

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
	L16 = 1 << 15
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
	PURPLE
}

func _ready() -> void:
	player = get_node("/root").find_child("Player", true, false)
	gui = get_node("/root").find_child("GUI", true, false)
	inventory_data = get_node("/root").find_child("InventoryData", true, false)

# Helper functions
func wait_for_animation_end(anim_player: AnimationPlayer, anim_name: String) -> void:
	while anim_player.current_animation != anim_name:
		await anim_player.animation_changed
	await anim_player.animation_finished

func debug_print(text, color: TextColor = TextColor.WHITE):
	var colorString = "white"
	match color:
		TextColor.RED:
			colorString = "red"
		TextColor.GREEN:
			colorString = "green"
		TextColor.BLUE:
			colorString = "blue"
		TextColor.YELLOW:
			colorString = "yellow"
		TextColor.CYAN:
			colorString = "cyan"
		TextColor.MAGENTA:
			colorString = "magenta"
		TextColor.WHITE:
			colorString = "white"
		TextColor.BLACK:
			colorString = "black"
		TextColor.GRAY:
			colorString = "gray"
		TextColor.ORANGE:
			colorString = "orange"
		TextColor.PINK:
			colorString = "pink"
		TextColor.PURPLE:
			colorString = "purple"
	print_rich("[color=%s]%s" % [colorString, text])
