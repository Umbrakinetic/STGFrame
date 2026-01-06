shader_type canvas_item;

// --- Uniforms --- //
uniform vec2 speed = vec2(1.0, 0.0);

uniform float alpha: hint_range(0.0, 1.0, 0.1);

// --- Functions --- //
void fragment() {
	COLOR = texture(TEXTURE, mod(UV + TIME * speed, 1.0));
	COLOR.a = COLOR.a * alpha;
}