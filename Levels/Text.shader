shader_type canvas_item;
render_mode skip_vertex_transform;

void vertex() {
	float frequence = 3.0;
    VERTEX = (EXTRA_MATRIX * (WORLD_MATRIX * vec4(VERTEX, 0.0, 1.0))).xy + vec2(0, 2.0*sin(frequence*TIME+VERTEX.x/30.0));
}