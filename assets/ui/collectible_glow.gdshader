shader_type canvas_item;

uniform float pulse : hint_range(0.0, 1.0) = 0.5;

void fragment() {
	vec4 col = texture(TEXTURE, UV);
	float glow = 0.35 + pulse * 0.65;
	col.rgb *= glow;
	col.a *= 0.85 + pulse * 0.15;
	COLOR = col;
}
