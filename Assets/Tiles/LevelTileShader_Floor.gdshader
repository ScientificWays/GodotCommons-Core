shader_type canvas_item;
//render_mode unshaded;

uniform sampler2D Tile: filter_nearest, source_color;

void fragment()
{
	//vec2 TileUV = mod(UV, TEXTURE_PIXEL_SIZE * 18.0) * vec2(2.0, 2.0);
	vec2 TileUV = UV / TEXTURE_PIXEL_SIZE * 16.0;
	COLOR *= texture(Tile, TileUV);
}
