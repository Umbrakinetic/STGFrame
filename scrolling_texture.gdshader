shader_type canvas_item;

// --- Uniforms --- //
uniform vec2 speed = vec2(1.0, 0.0);
uniform sampler2D texture;

// --- Functions --- //
void fragment() {
	vec4 color = texture(texture, mod(UV + TIME * speed, 1.0));
	color.a = COLOR.a;
	COLOR = color;
}