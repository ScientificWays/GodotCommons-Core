shader_type canvas_item;

uniform sampler2D tile: filter_nearest, source_color;
uniform sampler2D grass_overlay_stone: filter_nearest, source_color;
uniform vec4 grass_overlay_modulate: source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment()
{
	vec2 tile_uv = mod(UV, TEXTURE_PIXEL_SIZE * 18.0) * vec2(13.375, 4.375);
	vec4 tile_color = texture(tile, tile_uv);
	vec4 grass_color = texture(grass_overlay_stone, UV) * grass_overlay_modulate;
	COLOR *= mix(tile_color, grass_color, grass_color.a);
}
