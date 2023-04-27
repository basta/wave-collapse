shader_type canvas_item;

uniform vec4 color;
uniform sampler2D dataTexture;

void fragment() {
	float RESOLUTION = texture(dataTexture, vec2(0,0)).x * 10.;
	
	// Place fragment code here.\
	float x = floor(UV.x*RESOLUTION);
	float y = floor(UV.y*RESOLUTION);
	x = x/RESOLUTION;
	y = y/RESOLUTION;

	COLOR = vec4(x, y, 0, 1);
	
}
