shader_type canvas_item;
render_mode unshaded;

void fragment() {
	float wave = sin(TIME*1.5);

    float circle = UV.x * UV.x + UV.y * UV.y;
	
	vec3 colorVariation = mix(vec3(1, 0.6, 0.8), vec3(0.8, 1, 0.6), wave+circle);
    COLOR = vec4(colorVariation,1.0);
}