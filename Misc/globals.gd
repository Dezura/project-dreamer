extends Node

var player : Node3D

func _ready() -> void:
	player = get_node("/root").find_child("Player", true, false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
