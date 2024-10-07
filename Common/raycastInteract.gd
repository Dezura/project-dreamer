extends RayCast3D

@export var test : Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if get_collider() != null:
		if get_collider().owner.interactable:
			test.visible = true
			if Input.is_action_just_pressed("Interact"):
				if (get_collider() != null):
					get_collider().get_node("../").emit_signal("activated")
		else:
			test.visible = false
	else:
		test.visible = false
