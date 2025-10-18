shader_type canvas_item;
//render_mode unshaded;

uniform sampler2D Tile: filter_nearest, source_color;

void fragment()
{
	vec2 TileUV = mod(UV, TEXTURE_PIXEL_SIZE * 16.0) * vec2(13.5, 4.5);
	COLOR = texture(TEXTURE, UV) * texture(Tile, TileUV);
}
