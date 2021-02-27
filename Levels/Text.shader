shader_type canvas_item;
render_mode skip_vertex_transform;

void vertex() {
	float frequence = 2.0;
    VERTEX = (EXTRA_MATRIX * (WORLD_MATRIX * vec4(VERTEX, 0.0, 1.0))).xy;
	VERTEX.x -= 3.0*sin(VERTEX.y);
	VERTEX += vec2(0, 2.0*sin(frequence*TIME+VERTEX.x/40.0));
}