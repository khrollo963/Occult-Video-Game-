shader_type canvas_item;

uniform vec4 top_color : source_color = vec4(0.25, 0.12, 0.45, 1.0);
uniform vec4 bottom_color : source_color = vec4(0.12, 0.06, 0.22, 1.0);

void fragment() {
	COLOR = mix(bottom_color, top_color, UV.y);
}
