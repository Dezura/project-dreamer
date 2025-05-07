class_name InvItemBox
extends Button

signal item_use_pressed
signal item_inspect_pressed

var item_quantity: int = 0:
	set = set_item_quantity
var item_data: ItemResource:
	set = set_item_data

@onready var _click_options: PopupMenu = $ClickOptions
@onready var _quantity_label: Label = $QuantityLabel


#region Virtuals
func _ready() -> void:
	# Close popup menu on signal if inventory is closed
	g.gui.inventory_ui.menu_toggled.connect(_on_inventory_toggle_closed)


func _process(delta: float) -> void:
	if _click_options.visible:
		button_pressed = true
		# Get distance from center of popup box
		var distance_to_mouse_vec : Vector2i = _click_options.position - (get_global_mouse_position() as Vector2i) + _click_options.size/2
		# Close popup menu if mouse too far from edges of popup box
		if distance_to_mouse_vec.abs().x >= _click_options.size.x/2.0 + 30 or distance_to_mouse_vec.abs().y >= _click_options.size.y/2.0 + 30:
			_click_options.hide()
	else:
		button_pressed = false


func _pressed() -> void:
	# Spawn popup menu on mouse when itembox is pressed
	_click_options.position = get_global_mouse_position()
	_click_options.popup()
#endregion


func set_item_quantity(value: int) -> void:
	item_quantity = value
	
	if item_quantity > 1:
		_quantity_label.text = "x%s" % item_quantity
		_quantity_label.show()
	else:
		_quantity_label.hide()


func set_item_data(value: ItemResource) -> void:
	item_data = value
	
	text = item_data.visual_name
	tooltip_text = item_data.description
	
	if item_data.type == ItemResource.ItemType.CONSUMABLE:
		_click_options.add_item("Use Item")
	_click_options.add_item("Inspect")


func _use_item() -> void:
	item_use_pressed.emit()


func _inspect_item() -> void:
	item_inspect_pressed.emit()


func _combine_item() -> void:
	pass


func _on_popup_menu_clicked(choice_index: int) -> void:
	var option_string: String = _click_options.get_item_text(choice_index)
	match option_string:
		"Use Item":
			_use_item()
		"Inspect":
			_inspect_item()


func _on_inventory_toggle_closed(state: bool) -> void:
	_click_options.hide()
