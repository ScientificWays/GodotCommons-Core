shader_type canvas_item;
//render_mode unshaded;
render_mode blend_mix;

uniform vec3 Color: source_color = vec3(1.0, 1.0, 0.0);
uniform float AlphaMul = 1.0;
uniform float DefaultColorMul = 1.0;

void fragment() {

	vec4 DefaultColor = texture(TEXTURE, UV);
	//COLOR.rgb += COLOR.rgb * Color * 2.5;
	//COLOR *= vec4(vec3(1.0, 1.5, 1.0), DefaultColor.a * AlphaMul);
	
	// With textureGather()
	//vec4 Alphas = textureGather(TEXTURE, UV, 3);
	
	// With texture()
	float Top = texture(TEXTURE, UV + vec2(0.0, TEXTURE_PIXEL_SIZE.y)).a;
	float Right = texture(TEXTURE, UV + vec2(TEXTURE_PIXEL_SIZE.x, 0.0)).a;
	float Bottom = texture(TEXTURE, UV + vec2(0.0, -TEXTURE_PIXEL_SIZE.y)).a;
	float Left = texture(TEXTURE, UV + vec2(-TEXTURE_PIXEL_SIZE.x, 0.0)).a;
	vec4 Alphas = vec4(Top, Right, Bottom, Left);
	
	float GatheredAlpha = (Alphas.x + Alphas.y + Alphas.z + Alphas.w);
	float OutlineAlpha = step(1.0, GatheredAlpha) * (1.0 - step(4.0, GatheredAlpha)) * AlphaMul;
	
	//COLOR = DefaultColor + vec4(Color, OutlineAlpha) * (1.0 - DefaultColor.a);
	COLOR = DefaultColor * DefaultColorMul + vec4(Color, OutlineAlpha) * (1.0 - DefaultColor.a);
}
