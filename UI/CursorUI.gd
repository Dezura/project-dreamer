class_name CursorUI
extends Control

enum CustomCursorState{
	DEFAULT,
	HOVER_POINT
}
var _cursor_icon_default = load("res://Assets/Cursors/small_pointer_b.png")
var _cursor_icon_point = load("res://Assets/Cursors/small_hand_open.png")

var _last_cursor_pos : Vector2

func _ready() -> void:
	set_cursor_shape(CustomCursorState.DEFAULT)
	
	Input.set_custom_mouse_cursor(_cursor_icon_point, Input.CursorShape.CURSOR_DRAG, Vector2(17, 17))
	Input.set_custom_mouse_cursor(_cursor_icon_point, Input.CursorShape.CURSOR_POINTING_HAND, Vector2(17, 17))
	
	g.gui.get_node("InventoryUI").menu_toggled.connect(_on_inventory_ui_toggled)

func set_cursor_shape(state: CustomCursorState):
	match state:
		CustomCursorState.DEFAULT:
			Input.set_custom_mouse_cursor(_cursor_icon_default, Input.CursorShape.CURSOR_ARROW, Vector2(1, 1))
		CustomCursorState.HOVER_POINT:
			Input.set_custom_mouse_cursor(_cursor_icon_point, Input.CursorShape.CURSOR_ARROW, Vector2(17, 17))

func show_mouse():
	set_cursor_shape(CustomCursorState.DEFAULT)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_viewport().warp_mouse(_last_cursor_pos)

func hide_mouse(reset_pos : bool = false):
	_last_cursor_pos = get_viewport().get_mouse_position()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if reset_pos: _last_cursor_pos = get_viewport().get_mouse_position()

func _on_inventory_ui_toggled(state : bool):
	if g.gui.inventory_ui.is_menu_enabled:
		hide_mouse()
	else: 
		show_mouse()
