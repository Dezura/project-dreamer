class_name GUI
extends Control

@export var interfaceElements: Array[Control]

var _elementsHidden = false

func _process(delta: float):
	if Input.is_action_just_pressed("Open Inventory"):
		if !$Inventory.visible:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			hide_elements()
			$Inventory.show()
			g.player.immobile = true
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			show_elements()
			$Inventory.hide()
			g.player.immobile = false

func set_interaction_title(text: String):
	$"HUD/Interaction UI/ObjectTitle".text = text

func set_interaction_choice(text: String):
	$"HUD/Interaction UI/InteractionChoice".text = "[E] " + text

func hide_interaction():
	$"HUD/Interaction UI".visible = false

func show_interaction():
	if _elementsHidden: return
	$"HUD/Interaction UI".visible = true


func hide_elements():
	if _elementsHidden: return
	for element in interfaceElements:
		element.hide()
	_elementsHidden = true

func show_elements():
	if !_elementsHidden: return
	for element in interfaceElements:
		element.show()
	_elementsHidden = false
