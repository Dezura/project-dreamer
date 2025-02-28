class_name MouseClickable
extends CollisionObject3D

@export var clickable : bool = true:
	set(state):
		clickable = state
		if !clickable or g.gui_manager == null: return
		if mouse_hovering:
			mouse_entered.emit()
			g.gui_manager.set_cursor_shape(GUI.CustomCursorState.HOVER_POINT)
		else:
			mouse_exited.emit()
			g.gui_manager.set_cursor_shape(GUI.CustomCursorState.DEFAULT)

signal clicked

var mouse_hovering : bool = false

func _input_event(camera: Camera3D, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if !clickable: return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			g.debug_print("clicked %s [%s]" % [self.name, owner.name])
			clicked.emit()

func _mouse_enter() -> void:
	mouse_hovering = true
	if !clickable: return
	g.gui_manager.set_cursor_shape(GUI.CustomCursorState.HOVER_POINT)

func _mouse_exit() -> void:
	mouse_hovering = false
	if !clickable: return
	g.gui_manager.set_cursor_shape(GUI.CustomCursorState.DEFAULT)
