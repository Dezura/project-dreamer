extends RayCast3D

@export var test : Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	test.visible = is_colliding()
	if Input.is_action_just_pressed("Interact"):
		pass
