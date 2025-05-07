class_name InteractionUI
extends Control

signal menu_toggled(state: bool)

var _menu_enabled := false

@onready var _object_title_label: Label = $ObjectTitle
@onready var _interaction_choice_label: Label = $InteractionChoice


func set_interaction_title(text: String) -> void:
	_object_title_label.text = text


func set_interaction_choice(text: String) -> void:
	_interaction_choice_label.text = "[E] " + text


func set_menu_enabled(value: bool) -> void:
	_menu_enabled = value
	if g.gui.is_hud_hidden: 
		return
	self.visible = _menu_enabled
	
	menu_toggled.emit(_menu_enabled)


func toggle_menu_enabled() -> void:
	set_menu_enabled(not _menu_enabled)


func is_menu_enabled() -> bool:
	return _menu_enabled
