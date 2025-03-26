class_name Interactable
extends Node3D

signal interaction_pressed
signal selected_changed(state: bool)

enum HighlightState {
	NEUTRAL,
	ACTIVE_SELECT,
	PASSIVE_RANGE,
}

@export_placeholder("Enter UI title here") var interaction_title: String
@export_placeholder("Enter action name here") var interaction_text: String
@export_category("")
@export var _interact_meshes: Array[MeshInstance3D]

var interaction_disabled := false:
	set = set_interaction_disabled
var currently_selected := false
var current_highlight_state := HighlightState.NEUTRAL:
	set = set_current_highlight_state
var _player_radius_distance: float = 3.0 # Distance before player is considered in radius
var _player_is_in_radius := false

var _highlight_values: Dictionary = {
	HighlightState.ACTIVE_SELECT: {
		"enabled": true,
		"color": Color.YELLOW,
		"outline_enabled": true,
		"highlight_opacity": 0.2,
		"outline_opacity": 0.2
	},
	HighlightState.PASSIVE_RANGE: {
		"enabled": true,
		"color": Color.WHITE,
		"outline_enabled": true,
		"highlight_opacity": 0.1,
		"outline_opacity": 0.2
	},
	HighlightState.NEUTRAL: {
		"enabled": false,
		"color": Color.WHITE,
		"outline_enabled": false,
		"highlight_opacity": 0.0,
		"outline_opacity": 0.0
	}
}


#region Virtuals
func _ready() -> void:
	interaction_pressed.connect(_on_interaction_pressed)
	selected_changed.connect(_on_selected_changed)
	
	for mesh in _interact_meshes:
		mesh.material_overlay = preload("res://src/common/highlight_overlay.material").duplicate(true)


func _process(delta: float) -> void:
	if g.player.global_position.distance_to(global_position) <= _player_radius_distance:
		if !_player_is_in_radius:
			_player_is_in_radius = true
			_player_entered_radius()
	elif _player_is_in_radius:
		_player_is_in_radius = false
		_player_exited_radius()
#endregion


func set_interaction_disabled(value: bool) -> void:
	interaction_disabled = value
	check_current_highlight_state()


func set_current_highlight_state(value: HighlightState) -> void:
	if current_highlight_state == value: 
		return
	current_highlight_state = value
	
	for mesh in _interact_meshes:
		set_mesh_highlight(mesh, current_highlight_state)


func set_mesh_highlight(mesh: MeshInstance3D, state: HighlightState) -> void:
	var highlight_material: ShaderMaterial = mesh.material_overlay
	var outline_material: ShaderMaterial = highlight_material.next_pass
	if _highlight_values[state].enabled:
		highlight_material.set_shader_parameter("enabled", true)
		highlight_material.set_shader_parameter("highlight_opacity", 0.1*_highlight_values[state].highlight_opacity)
		highlight_material.set_shader_parameter("highlight_color", _highlight_values[state].color)
		if _highlight_values[state].outline_enabled:
			outline_material.set_shader_parameter("enabled", true)
			outline_material.set_shader_parameter("transparency", 0.1*_highlight_values[state].outline_opacity)
			outline_material.set_shader_parameter("outline_color", _highlight_values[state].color)
		else: 
			outline_material.set_shader_parameter("enabled", false)
	else:
		highlight_material.set_shader_parameter("enabled", false)
		outline_material.set_shader_parameter("enabled", false)


func check_current_highlight_state() -> void:
	if currently_selected:
		current_highlight_state = HighlightState.ACTIVE_SELECT
	elif _player_is_in_radius and !interaction_disabled:
		current_highlight_state = HighlightState.PASSIVE_RANGE
	else:
		current_highlight_state = HighlightState.NEUTRAL


# Update interactable logic while in range of player
func _player_entered_radius() -> void: 
	if !interaction_disabled: current_highlight_state = HighlightState.PASSIVE_RANGE


func _player_exited_radius() -> void:
	current_highlight_state = HighlightState.NEUTRAL


# Catch when player hits interact button while actively selected
func _on_interaction_pressed() -> void:
	g.debug_print("Started Interaction '%s' on '%s' [%s]" % [interaction_text, interaction_title, self.name], g.TextColor.GRAY)


# Catch when player is actively selecting/deselecting object
func _on_selected_changed(state: bool) -> void:
	currently_selected = state
	if state: g.debug_print("  select [%s]" % self.name, g.TextColor.PINK)
	else: g.debug_print("  deselect [%s]" % self.name, g.TextColor.PINK)
	check_current_highlight_state()
