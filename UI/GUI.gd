class_name GUI
extends Control

@onready var cursor_ui : CursorUI = $CursorUI
@onready var interaction_ui : InteractionUI = $HUD/InteractionUI
@onready var inventory_ui : InventoryUI = $InventoryUI

var is_hud_hidden : bool = false

func _ready() -> void:
	inventory_ui.menu_toggled.connect(_on_inventory_ui_toggled)
	
	# Hide mouse at start and reset it's position to middle of screen
	cursor_ui.hide_mouse(true)
	
	# Hide all random elements and show regular starting menu HUD
	for ui_menu in [interaction_ui, inventory_ui]:
		ui_menu.set_menu(false)
	$HUD.show()

func _on_inventory_ui_toggled(state : bool):
	$HUD.visible = !inventory_ui.is_menu_enabled

func turn_off_hud() -> void:
	if is_hud_hidden: return
	
	$HUD.hide()
	interaction_ui.set_menu(false)
	is_hud_hidden = true

func turn_on_hud() -> void:
	if !is_hud_hidden: return
	
	$HUD.show()
	interaction_ui.set_menu(true)
	is_hud_hidden = false
