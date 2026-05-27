shader_type canvas_item;
render_mode blend_add;

uniform float speed = 0.55;
uniform float band_width = 0.22;
uniform float intensity = 0.42;

void fragment() {
	float sweep = fract(TIME * speed);
	float leading = smoothstep(sweep - band_width, sweep, UV.x);
	float trailing = 1.0 - smoothstep(sweep, sweep + band_width * 0.65, UV.x);
	float band = leading * trailing;
	float vertical_fade = smoothstep(0.08, 0.35, UV.y) * (1.0 - smoothstep(0.65, 0.92, UV.y));
	COLOR = vec4(1.0, 0.98, 0.88, band * vertical_fade * intensity);
}
