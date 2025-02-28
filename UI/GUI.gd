class_name GUI
extends Control

@export var interfaceElements: Array[Control]

var _elementsHidden = false

enum CustomCursorState{
	DEFAULT,
	HOVER_POINT
}
var _cursor_icon_default = load("res://Assets/Cursors/small_pointer_b.png")
var _cursor_icon_point = load("res://Assets/Cursors/small_hand_open.png")

var _last_cursor_pos : Vector2

func _ready() -> void:
	hide_interaction()
	hide_mouse(true)
	
	set_cursor_shape(CustomCursorState.DEFAULT)
	
	Input.set_custom_mouse_cursor(_cursor_icon_point, Input.CursorShape.CURSOR_DRAG, Vector2(17, 17))
	Input.set_custom_mouse_cursor(_cursor_icon_point, Input.CursorShape.CURSOR_POINTING_HAND, Vector2(17, 17))

func _process(delta: float):
	if Input.is_action_just_pressed("Open Inventory"):
		if !$Inventory.visible:
			show_mouse()
			hide_elements()
			$Inventory.show()
			g.player.immobile = true
			g.player.interaction_disabled = true
		else:
			hide_mouse()
			show_elements()
			$Inventory.hide()
			g.player.immobile = false
			g.player.interaction_disabled = false

func set_cursor_shape(state: CustomCursorState):
	match state:
		CustomCursorState.DEFAULT:
			Input.set_custom_mouse_cursor(_cursor_icon_default, Input.CursorShape.CURSOR_ARROW, Vector2(3, 3))
		CustomCursorState.HOVER_POINT:
			Input.set_custom_mouse_cursor(_cursor_icon_point, Input.CursorShape.CURSOR_ARROW, Vector2(17, 17))

func set_interaction_title(text: String):
	$"HUD/Interaction UI/ObjectTitle".text = text

func set_interaction_choice(text: String):
	$"HUD/Interaction UI/InteractionChoice".text = "[E] " + text

func show_mouse():
	set_cursor_shape(CustomCursorState.DEFAULT)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_viewport().warp_mouse(_last_cursor_pos)
func hide_mouse(reset_pos : bool = false):
	_last_cursor_pos = get_viewport().get_mouse_position()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if reset_pos: _last_cursor_pos = get_viewport().get_mouse_position()

func hide_interaction():
	$"HUD/Interaction UI".visible = false
func show_interaction():
	if _elementsHidden: return
	$"HUD/Interaction UI".visible = true

func hide_elements():
	if _elementsHidden: return
	for element in interfaceElements:
		element.hide()
	_elementsHidden = true
func show_elements():
	if !_elementsHidden: return
	for element in interfaceElements:
		element.show()
	_elementsHidden = false
