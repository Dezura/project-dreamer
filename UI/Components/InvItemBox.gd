class_name InvItemBox
extends Button

signal item_use_pressed
signal item_inspect_pressed

var item_quantity : int = 0:
	set(value):
		item_quantity = value
		
		if item_quantity > 1:
			$QuantityLabel.text = "x%s" % item_quantity
			$QuantityLabel.show()
		else:
			$QuantityLabel.hide()
var item_data : ItemResource:
	set(data):
		item_data = data
		
		text = item_data.visual_name
		tooltip_text = item_data.description
		
		if item_data.type == ItemResource.ItemType.CONSUMABLE:
			$ClickOptions.add_item("Use Item")
		$ClickOptions.add_item("Inspect")

func _ready() -> void:
	# Close popup menu on signal if inventory is closed
	g.gui.inventory_ui.menu_toggled.connect(_on_inventory_toggle_closed)

func _on_use_item():
	pass

func _on_inspect_item():
	pass

func _on_combine_item():
	pass

#region Core
func _pressed() -> void:
	# Spawn popup menu on mouse when itembox is pressed
	$ClickOptions.position = get_global_mouse_position()
	$ClickOptions.popup()

func _process(delta: float) -> void:
	if $ClickOptions.visible:
		button_pressed = true
		# Get distance from center of popup box
		var distance_to_mouse_vec : Vector2i = $ClickOptions.position - (get_global_mouse_position() as Vector2i) + $ClickOptions.size/2
		# Close popup menu if mouse too far from edges of popup box
		if distance_to_mouse_vec.abs().x >= $ClickOptions.size.x/2 + 30 or distance_to_mouse_vec.abs().y >= $ClickOptions.size.y/2 + 30:
			$ClickOptions.hide()
	else:
		button_pressed = false

func _on_popup_menu_clicked(choice_index : int):
	var option_string = $ClickOptions.get_item_text(choice_index)
	match option_string:
		"Use Item":
			item_use_pressed.emit()
			g.inventory_data.try_consume_item(item_data.identifer, 1)
		"Inspect":
			item_inspect_pressed.emit()

func _on_inventory_toggle_closed(state : bool):
	$ClickOptions.hide()
#endregion
