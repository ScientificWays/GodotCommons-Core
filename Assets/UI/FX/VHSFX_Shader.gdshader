shader_type canvas_item;

uniform float time_speed : hint_range(0.0, 10.0) = 1.0;
uniform float split_amount : hint_range(0.0, 5.0) = 1.5;
uniform float flicker_intensity : hint_range(0.0, 1.0) = 0.2;
uniform float noise_strength : hint_range(0.0, 0.5) = 0.05;

float rand(vec2 co)
{
	return fract(sin(dot(co.xy, vec2(12.9898,78.233))) * 43758.5453);
}

void fragment()
{
	vec2 uv = UV;
	float t = TIME * time_speed;
	
	vec2 pixel = TEXTURE_PIXEL_SIZE * split_amount;
	
	// RGB split
	float r = texture(TEXTURE, uv + vec2(pixel.x * sin(t * 1.7), pixel.y * cos(t * 1.3))).r;
	float g = texture(TEXTURE, uv).g;
	float b = texture(TEXTURE, uv - vec2(pixel.x * cos(t * 1.1), pixel.y * sin(t * 1.9))).b;
	
	vec3 color = vec3(r, g, b);
	
	// Flicker
	float flicker = 1.0 - (rand(vec2(t, uv.y)) * flicker_intensity);
	
	// VHS
	float noise = (rand(uv * t) - 0.5) * noise_strength;
	
	COLOR = vec4(color * flicker + noise, texture(TEXTURE, uv).a * COLOR.a);
}
