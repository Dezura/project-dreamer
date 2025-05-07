class_name MouseClickable
extends CollisionObject3D

signal clicked

@export var clickable: bool = true:
	set = set_clickable

var mouse_hovering: bool = false


#region Virtuals
func _input_event(camera: Camera3D, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if not clickable: 
		return
	if event is InputEventMouseButton:
		@warning_ignore("unsafe_property_access") # THIS IS A FALSE POSITIVE, GODOT PLEASE FIX THIS BRO
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			g.debug_print("clicked %s [%s]" % [self.name, owner.name])
			clicked.emit()


func _mouse_enter() -> void:
	mouse_hovering = true
	if not clickable: 
		return
	g.gui.cursor_ui.set_cursor_shape(CursorUI.CustomCursorState.HOVER_POINT)


func _mouse_exit() -> void:
	mouse_hovering = false
	if not clickable: 
		return
	g.gui.cursor_ui.set_cursor_shape(CursorUI.CustomCursorState.DEFAULT)
#endregion


func set_clickable(value: bool) -> void:
	clickable = value
	if not clickable or g.gui == null: 
		return
	if mouse_hovering:
		mouse_entered.emit()
		g.gui.cursor_ui.set_cursor_shape(CursorUI.CustomCursorState.HOVER_POINT)
	else:
		mouse_exited.emit()
		g.gui.cursor_ui.set_cursor_shape(CursorUI.CustomCursorState.DEFAULT)
