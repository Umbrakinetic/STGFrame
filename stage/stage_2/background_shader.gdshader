shader_type spatial;
render_mode unshaded;

uniform sampler2D tex;

uniform vec2 scroll;

global uniform bool paused;

void fragment () {
	vec4 tex_color = texture(tex, UV + (scroll * TIME * (1.0 - float(paused))));
	ALBEDO = vec3(tex_color.r, tex_color.g, tex_color.b);
	ALPHA = (UV.y * 2.0) - (0.6);
}
