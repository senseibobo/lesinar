shader_type spatial;


uniform sampler2D heightmap: filter_nearest;
uniform sampler2D albedo_texture;
uniform float amplitude = 8.0;

float get_height(vec3 vertex) {
	vec2 texture_position = (vertex.xz + vec2(0.5))/float(textureSize(heightmap, 0).x);
	return (texture(heightmap, texture_position).r-0.5) * amplitude;
}

vec3 get_normal(vec3 vertex, float adjacent_distance) {
	vec3 west_vert = vertex + vec3(adjacent_distance,0,0);
	west_vert.y = get_height(west_vert);
	vec3 north_vert = vertex + vec3(0,0,adjacent_distance);
	north_vert.y = get_height(north_vert);
	return normalize(
		cross(
			north_vert-vertex,
			west_vert-vertex
		)
	);
}


void vertex() {
	NORMAL = get_normal(VERTEX, 5.0);
	VERTEX.y -= pow(textureLod(heightmap, UV,1.0).r,0.3)*amplitude;
	COLOR.rgb = vec3(VERTEX.y)/1.0;
	// Called for every vertex the material is visible on.
}

void fragment() {
	ALBEDO.r = step(1.0,mod(UV.x*30.0,2.0))/3.0;
	ALBEDO.b = step(1.0,mod(UV.y*30.0,2.0))/3.0;
	ALBEDO.g = 1.0;
	ALBEDO /= 2.0;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
