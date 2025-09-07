shader_type canvas_item;

uniform sampler2D Tile : filter_nearest, source_color;
uniform sampler2D GrassOverlay_Dirt : filter_nearest, source_color;

uniform vec2 GrassOverlay_EmissiveMul = vec2(0.0, 0.0);

void fragment()
{
	vec2 TileUV = mod(UV, TEXTURE_PIXEL_SIZE * 18.0) * vec2(13.375, 4.375);
	vec4 TileColor = texture(Tile, TileUV);
	vec4 GrassColor = texture(GrassOverlay_Dirt, UV) * (1.0 + GrassOverlay_EmissiveMul.x);
	//COLOR = texture(TEXTURE, UV) * TileColor;
	COLOR = texture(TEXTURE, UV) * mix(TileColor, GrassColor, GrassColor.a);
}
