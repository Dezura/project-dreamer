@tool
class_name Room
extends StaticBody3D

@export var room_name : String
@export var attached_doors : Array[Door]

@export_category("Lighting")

var _room_lights : Array[ConfigurableLight]
@export var room_light_color : Color = 0xb3deffff:
	set(value):
		room_light_color = value
		_update_room_light_values()

@export_range(0.0, 5.0) var room_light_strength : float = 1.0:
	set(value):
		room_light_strength = value
		_update_room_light_values()

var is_loaded := true

func _ready() -> void:
	_update_room_light_values()
	if Engine.is_editor_hint(): return
	unload_area()

func _on_entity_entered_area(collisionBody: Node3D) -> void:
	if collisionBody == g.player and g.player.current_room != self:
		g.player._on_entered_room(self)
		load_area()

func load_area() -> void:
	if is_loaded: return
	
	g.debug_print("Loading area [%s]" % name, g.TextColor.YELLOW)
	self.show()
	
	is_loaded = true
func unload_area() -> void:
	if !is_loaded: return
	
	g.debug_print("Unloading area [%s]" % name, g.TextColor.RED)
	self.hide()
	
	is_loaded = false

func disable_lights() -> void:
	for light in _room_lights:
		light.turn_off()
func enable_lights() -> void:
	for light in _room_lights:
		light.turn_on()

func _update_room_light_values():
	if $room_lights.get_child_count() != _room_lights.size(): _room_lights.assign($room_lights.get_children())
	for light in _room_lights:
			if light != null:
				light.light_color = room_light_color
				light.light_multiplier = room_light_strength
