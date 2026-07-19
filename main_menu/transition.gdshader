shader_type canvas_item;

uniform float screen_cover : hint_range(0.0, 1.0) = 0.5;

uniform sampler2D noise;

void fragment() {
	vec4 noise_color = texture(noise, UV);
	
	float progress = 0.0;
	
	progress =  screen_cover / UV.y;
	
	noise_color.a = mix(min(noise_color.a / 10.0, 0.0), noise_color.a + max(noise_color.a * 10.0, 1.0), progress);
	
	COLOR = noise_color;
}
