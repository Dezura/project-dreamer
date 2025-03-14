class_name InteractionUI
extends Control

signal menu_toggled(state : bool)
var is_menu_enabled : bool = false

#region Core
func _ready() -> void:
	menu_toggled.connect(_on_interaction_menu_toggled)

func toggle_menu():
	menu_toggled.emit(!is_menu_enabled)
func set_menu(state):
	menu_toggled.emit(state)

func _on_interaction_menu_toggled(to_state : bool):
	is_menu_enabled = to_state
	if g.gui.is_hud_hidden: return
	self.visible = is_menu_enabled
#endregion


func set_interaction_title(text: String):
	$ObjectTitle.text = text

func set_interaction_choice(text: String):
	$InteractionChoice.text = "[E] " + text
