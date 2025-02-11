class_name Interactable
extends Node3D

signal activated
var interactable : bool = true

@export_placeholder("Enter UI title here") var title: String
@export_placeholder("Enter action name here") var interactionText: String
@export_category("")

func _ready():
	activated.connect(Callable(self, "_on_interaction"))

func _on_interaction():
	pass
