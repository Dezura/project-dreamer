@tool
class_name Room
extends StaticBody3D

@export var room_name: String
@export var attached_doors: Array[Door]
@export_category("Lighting")
@export var room_light_color := Color(0xb3deffff):
	set = set_room_light_color
@export_range(0.0, 5.0) var room_light_strength: float = 1.0:
	set = set_room_light_strength

var is_loaded := true
var _room_lights: Array[ConfigurableLight]

#region Virtuals
func _ready() -> void:
	_update_room_light_values()
	if Engine.is_editor_hint(): 
		return
	
	unload_area()
#endregion


func set_room_light_color(value: Color) -> void:
	room_light_color = value
	_update_room_light_values()


func set_room_light_strength(value: float) -> void:
	room_light_strength = value
	_update_room_light_values()


func load_area() -> void:
	if is_loaded: 
		return
	
	g.debug_print("Loading area [%s]" % name, g.TextColor.YELLOW)
	self.show()
	is_loaded = true


func unload_area() -> void:
	if not is_loaded: 
		return
	
	g.debug_print("Unloading area [%s]" % name, g.TextColor.RED)
	self.hide()
	is_loaded = false


func enable_lights() -> void:
	for light in _room_lights:
		light.turn_on()


func disable_lights() -> void:
	for light in _room_lights:
		light.turn_off()


# Set each individual main light to match overall room light color and strength values
func _update_room_light_values() -> void:
	# Make sure children under room_light holder are accurate before setting
	if $room_lights.get_child_count() != _room_lights.size(): 
		_room_lights.assign($room_lights.get_children())
	
	for light in _room_lights:
			if light != null:
				light.light_color = room_light_color
				light.light_multiplier = room_light_strength


func _on_entity_entered_area(collisionBody: Node3D) -> void:
	if collisionBody == g.player and g.player.current_room != self:
		g.player._on_entered_room(self)
		load_area()
