// NOTE: Shader automatically converted from Godot Engine 4.4.rc1's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

uniform bool enabled = true;

uniform vec3 highlight_color : source_color = vec3(1.0, 1.0, 1.0);
uniform float highlight_opacity : hint_range(0.0, 0.25, 0.01) = 0.75;

uniform float emission_energy : hint_range(0.0, 20.0, 0.5) = 2;

void vertex() {

}

void fragment() {
	if (enabled) {
		ALBEDO = highlight_color.rgb;
		EMISSION = highlight_color.rgb * emission_energy;
		ALPHA = highlight_opacity;
	}
	else {
		ALPHA = 0.0;
	}
}
