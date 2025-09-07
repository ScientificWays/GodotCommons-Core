shader_type canvas_item;

//uniform sampler2D Normal : filter_nearest, hint_normal;

uniform sampler2D Mask : filter_nearest, hint_default_transparent;
uniform float Mul = 1.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

//void fragment() {
//	COLOR = texture(TEXTURE, UV);
//}

void light() {

	float cNdotL = max(0.0, dot(NORMAL, LIGHT_DIRECTION));
	vec3 DefaultLight = COLOR.rgb * LIGHT_COLOR.rgb * cNdotL;

	vec3 EmissiveLight = COLOR.rgb * texture(Mask, UV).r * Mul;
	LIGHT = vec4(DefaultLight + EmissiveLight, LIGHT_COLOR.a);
}
