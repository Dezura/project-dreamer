class_name Interactable
extends Node3D

signal interaction_pressed
signal selected(state : bool)
var interaction_disabled : bool = false:
	set(value):
		interaction_disabled = value
		check_current_highlight_state()
var currently_selected : bool = false

@export_placeholder("Enter UI title here") var interaction_title: String
@export_placeholder("Enter action name here") var interaction_text: String
@export_category("")

var _player_is_in_radius : bool = false
var _player_radius_distance := 3.0
@export var _interact_meshes : Array[MeshInstance3D]

enum HighlightState {
	NEUTRAL,
	ACTIVE_SELECT,
	PASSIVE_RANGE
}
var current_highlight_state := HighlightState.NEUTRAL:
	set(state):
		if current_highlight_state == state: return
		current_highlight_state = state
		for mesh in _interact_meshes:
			set_mesh_highlight(mesh, state)
var _highlight_values : Dictionary = {
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

func _ready() -> void:
	interaction_pressed.connect(Callable(self, "_on_interaction_pressed"))
	selected.connect(Callable(self, "_on_selected_changed"))
	
	for mesh in _interact_meshes:
		mesh.material_overlay = preload("res://Textures/interactive_highlight.tres").duplicate(true)

#region Override Functions
# Update interactable logic while in range of player
func _on_player_entered_radius() -> void: 
	if !interaction_disabled: current_highlight_state = HighlightState.PASSIVE_RANGE
func _on_player_exited_radius() -> void:
	current_highlight_state = HighlightState.NEUTRAL

# Catch when player hits interact button while actively selected
func _on_interaction_pressed() -> void:
	g.debug_print("Started Interaction '%s' on '%s' [%s]" % [interaction_text, interaction_title, self.name], g.TextColor.GRAY)

# Catch when player is actively selecting/deselecting object
func _on_selected_changed(state : bool) -> void:
	currently_selected = state
	if state: g.debug_print("  select [%s]" % self.name, g.TextColor.PINK)
	else: g.debug_print("  deselect [%s]" % self.name, g.TextColor.PINK)
	check_current_highlight_state()
#endregion

func _process(delta: float) -> void:
	if g.player.global_position.distance_to(global_position) <= _player_radius_distance:
		if !_player_is_in_radius:
			_player_is_in_radius = true
			_on_player_entered_radius()
	elif _player_is_in_radius:
		_player_is_in_radius = false
		_on_player_exited_radius()

func set_mesh_highlight(mesh: MeshInstance3D, state : HighlightState) -> void:
	if _highlight_values[state].enabled:
		mesh.material_overlay.set_shader_parameter("enabled", true)
		mesh.material_overlay.set_shader_parameter("highlight_opacity", 0.1*_highlight_values[state].highlight_opacity)
		mesh.material_overlay.set_shader_parameter("highlight_color", _highlight_values[state].color)
		if _highlight_values[state].outline_enabled:
			mesh.material_overlay.next_pass.set_shader_parameter("enabled", true)
			mesh.material_overlay.next_pass.set_shader_parameter("transparency", 0.1*_highlight_values[state].outline_opacity)
			mesh.material_overlay.next_pass.set_shader_parameter("outline_color", _highlight_values[state].color)
		else: 
			mesh.material_overlay.next_pass.set_shader_parameter("enabled", false)
	else:
		mesh.material_overlay.set_shader_parameter("enabled", false)
		mesh.material_overlay.next_pass.set_shader_parameter("enabled", false)

func check_current_highlight_state():
	if currently_selected:
		current_highlight_state = HighlightState.ACTIVE_SELECT
	elif _player_is_in_radius and !interaction_disabled:
		current_highlight_state = HighlightState.PASSIVE_RANGE
	else:
		current_highlight_state = HighlightState.NEUTRAL
