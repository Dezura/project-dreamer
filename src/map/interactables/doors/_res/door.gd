class_name Door
extends Interactable

@export var connectedRoomA : Room
@export var connectedRoomB : Room

var _is_opened : bool = false

@onready var _door_animations: AnimationPlayer = $DoorAnimations


#region Virtuals
func _ready() -> void:
	super()
	
	_highlight_values[HighlightState.PASSIVE_RANGE].highlight_opacity /= 2.0
	_highlight_values[HighlightState.PASSIVE_RANGE].outline_opacity /= 8.0
	_highlight_values[HighlightState.ACTIVE_SELECT].outline_opacity /= 2.5


func _process(delta: float) -> void:
	super(delta)
	
	if _is_opened:
		var distanceToPlayer := global_position.distance_to(g.player.global_position)
		if distanceToPlayer > 3.0:
			close_door()
			
			await g.wait_for_animation_end(_door_animations, "door_close")
			get_flipped_room(g.player.current_room).unload_area()


func _on_interaction_pressed() -> void:
	super()
	
	_door_open_interaction(g.player.current_room, get_flipped_room(g.player.current_room))
#endregion

func open_door() -> void:
	interaction_disabled = true
	_door_animations.play("door_open")


func close_door() -> void:
	_door_animations.play("door_close")


func get_flipped_room(from_room : Room) -> Room:
	# If starting from room A, then set interaction text to B
	if from_room == connectedRoomA:
		return connectedRoomB
	# Vice versa
	else:
		return connectedRoomA


# Derive from this in door subclasses
func _door_open_interaction(initial_room: Room, target_room: Room) -> void:
	# Load new room before opening
	target_room.load_area()
	
	open_door()

func _on_door_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"door_open":
			_is_opened = true
		"door_close":
			_is_opened = false
			interaction_disabled = false
