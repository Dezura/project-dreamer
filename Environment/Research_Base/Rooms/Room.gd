class_name Room
extends StaticBody3D

@export var room_name : String
@export var attached_doors : Array[Door]
var _lights : Array[ConfigurableLight]

var is_loaded := true

func _ready() -> void:
	for light: ConfigurableLight in find_children("*", "ConfigurableLight"):
		_lights.append(light)
	
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
	for light in _lights:
		light.turn_off()
func enable_lights() -> void:
	for light in _lights:
		light.turn_on()
