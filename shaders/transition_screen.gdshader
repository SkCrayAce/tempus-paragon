shader_type canvas_item;

//uniform float pixelFactor : hint_range(0, 1) = 0.5;
uniform float pixel_size : hint_range(1.0, 16.0, 1.0) = 1.0;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, repeat_disable, filter_nearest;

void fragment() {
	float x = FRAGCOORD.x - mod(FRAGCOORD.x, pixel_size);
	float y = FRAGCOORD.y - mod(FRAGCOORD.y, pixel_size);
	float shift = floor(pixel_size / 2.0);
	//vec2 pixelNumber = vec2(textureSize(TEXTURE, 0)) * pixelFactor;
	//vec2 pixelatedUV = round(UV * pixelNumber) / pixelNumber;
	COLOR = texture(SCREEN_TEXTURE, vec2(x + shift, y + shift) * SCREEN_PIXEL_SIZE);
}


