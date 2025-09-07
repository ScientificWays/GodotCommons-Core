shader_type canvas_item;

uniform vec3 Color: source_color = vec3(0.05, 0.05, 0.05);

void fragment() {
	COLOR = vec4(Color, texture(TEXTURE, UV).a);
}
