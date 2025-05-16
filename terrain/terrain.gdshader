shader_type spatial;
render_mode blend_mix, depth_draw_opaque;


uniform sampler2D heightmap: filter_nearest;
uniform sampler2D albedo_texture;
uniform float amplitude = 8.0;

float get_height(vec3 vertex) {
	vec2 texture_position = (vertex.xz + vec2(0.5))/float(textureSize(heightmap, 0).x);
	return (texture(heightmap, texture_position).r-0.5) * amplitude;
}

vec3 get_normal(vec3 vertex, float d) {
    float hL = get_height(vertex + vec3(-d, 0, 0)); // left (west)
    float hR = get_height(vertex + vec3( d, 0, 0)); // right (east)
    float hD = get_height(vertex + vec3(0, 0, -d)); // down (south)
    float hU = get_height(vertex + vec3(0, 0,  d)); // up (north)

    vec3 normal = vec3(hL - hR, 2.0 * d, hD - hU);
    return normalize(normal);
}


void vertex() {
	NORMAL = get_normal(VERTEX, 0.1);
	VERTEX.y -= pow(textureLod(heightmap, UV,1.0).r,0.3)*amplitude;
	COLOR.rgb = vec3(VERTEX.y)/1.0;
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec3 old_albedo = ALBEDO;
	ALBEDO.r = step(1.0,mod(UV.x*30.0,2.0))/4.0;
	ALBEDO.b = step(1.0,mod(UV.y*30.0,2.0))/8.0;
	ALBEDO.g = 0.7;
	ALBEDO /= 2.0;
	ALBEDO *= texture(albedo_texture, UV*15.0).rgb;
	//ALBEDO = ALBEDO*old_albedo;
}

void light() {
    DIFFUSE_LIGHT += abs(dot(NORMAL, LIGHT) * ATTENUATION * ALBEDO);
}
