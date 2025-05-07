class_name GUI
extends Control

var is_hud_hidden := false

@onready var cursor_ui: CursorUI = $CursorUI
@onready var interaction_ui: InteractionUI = $HUD/InteractionUI
@onready var inventory_ui: InventoryUI = $InventoryUI
@onready var _hud: Control = $HUD


#region Virtuals
func _ready() -> void:
	inventory_ui.menu_toggled.connect(_on_inventory_ui_toggled)
	inventory_ui.menu_toggled.connect(cursor_ui._on_inventory_ui_toggled)
	
	# Hide mouse at start and reset it's position to middle of screen
	cursor_ui.hide_mouse(true)
	
	# Hide all random elements and show regular starting menu HUD
	interaction_ui.set_menu_enabled(false)
	inventory_ui.set_menu_enabled(false)
	_hud.show()
#endregion


func turn_on_hud() -> void:
	if !is_hud_hidden: 
		return
	
	_hud.show()
	interaction_ui.set_menu_enabled(true)
	is_hud_hidden = false


func turn_off_hud() -> void:
	if is_hud_hidden: 
		return
	
	_hud.hide()
	interaction_ui.set_menu_enabled(false)
	is_hud_hidden = true


func _on_inventory_ui_toggled(state: bool) -> void:
	_hud.visible = not inventory_ui.is_menu_enabled()
