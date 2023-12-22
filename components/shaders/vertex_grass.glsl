/*
	// = object.matrixWorld
	uniform mat4 modelMatrix;

	// = camera.matrixWorldInverse * object.matrixWorld
	uniform mat4 modelViewMatrix;

	// = camera.projectionMatrix
	uniform mat4 projectionMatrix;

	// = camera.matrixWorldInverse
	uniform mat4 viewMatrix;

	// = inverse transpose of modelViewMatrix
	uniform mat3 normalMatrix;

	// = camera position in world space
	uniform vec3 cameraPosition;

	// default vertex attributes provided by BufferGeometry
	attribute vec3 position;
	attribute vec3 normal;
	attribute vec2 uv;
*/ 

uniform sampler2D u_height_map_texture;
uniform float u_displacement;

uniform float u_param;

uniform float u_instance_count;
uniform float u_time;
uniform float u_amplitude;
uniform float u_posy;
uniform float u_posx;
uniform vec3 u_vertex_displacement;
uniform vec2 u_dimensions;
uniform float u_noise;
uniform bool u_animate;

varying vec2 vUv;
varying vec3 v_normal;
varying float v_time;

varying float v_directional_light_intensity;
varying vec3 v_directional_light_color;

varying vec3 v_uv_texture_debug;

// float is just for annoying type conversiodns
flat varying float v_instance;

// the direction of the light is specified in worldspace
// therefore, to properly computer the lighting, we required the normals
// to be transformed from model space to world space
#if NUM_DIR_LIGHTS > 0
	struct DirectionalLight {
		vec3 direction;
		vec3 color;
	};
	uniform DirectionalLight directionalLights[ NUM_DIR_LIGHTS ];
#endif

vec4 quat_from_axis_angle(vec3 axis, float angle){ 
	vec4 qr;
	float half_angle = (angle * 0.5) * 3.14159 / 180.0;
	qr.x = axis.x * sin(half_angle);
	qr.y = axis.y * sin(half_angle);
	qr.z = axis.z * sin(half_angle);
	qr.w = cos(half_angle);
	return qr;
}

vec3 rotate_vertex_position(vec3 position, vec3 axis, float angle){

	vec4 q = quat_from_axis_angle(axis, angle);
	vec3 v = position.xyz;
	return v + 2.0 * cross(q.xyz, cross(q.xyz, v) + q.w * v);

}

// TODO: flow control implementation to see wether a single blade of grass gets rendered or not
void main() {
	v_time = u_time;
	vUv = uv;
	v_normal = normal;
	v_instance = float(gl_InstanceID);
	
	float width = float(u_dimensions.x);
	float dimension = float(u_dimensions.y);

	vec3 finalPosition = position;

	float intensity = dot(normal, directionalLights[0].direction);
	// TODO: max function isn't available, what version am i using?
	v_directional_light_intensity = (intensity > 0.0) ? intensity : 0.0;
	v_directional_light_color = directionalLights[0].color;

	// noise function noise(x,y,u_time), use the resolution of the canvas 
	// or for example 100x100 according to the value of the instance, which is the only
	// none constant variable, make a mathematical formula for getting x,y coordinates within 
	// 100x100 according to instance
	// variable which iterates over 0->10000 

	// TODO:
	// Asses a somewhat issue where the number of instances does not
	// evenly fill out the rest of the plane, i would also like to simulate clumping
	// POSSIBLE SOLUTIONS:
	// * Add more density or noise into each instanced grass position
	// 		it would mess up the distribution,
	// 		calculate if the particular instance exeeds the width and dimension bounds
	// 		then to each time it exceeds the bounds, add an offset x,y noise factor 
	//		(make into a uniform) to simulate density
	// * implement some form of dynamic chunking
	// 		it would keep the keep the distribution uniform

	// TODO:
	// Render the grass according to terrain heightmap texture

	// total instance percentage of current instance
	float a = ((v_instance / (width * dimension)) / u_instance_count) * 100.0;
	// current position
	float x = mod(v_instance,width);
	float y = mod((v_instance / dimension), width);

	float noise_cache = snoise(vec2(x,y));
	float final_noise = snoise(vec2(x,y) * (u_animate ? ((cos((u_time*0.5)))*u_noise) : u_noise));

	float angle = noise_cache * 360.0;
	finalPosition.y += 0.5;

	finalPosition.y += finalPosition.y * noise_cache;
	finalPosition.xy *= vec2(u_posx, u_posy);

	// grass sway
	if(finalPosition.y > 0.5) {
		finalPosition.x = ( finalPosition.x + sin( u_time/0.5* ( angle*0.01 ) )  * u_amplitude);
		finalPosition.z = ( finalPosition.z + cos( u_time/0.5* ( angle*0.01 ) )  * u_amplitude);	
	}

	vec3 axist = vec3(0.0, 0.5, 0.0); // grass rotation
	finalPosition = rotate_vertex_position(finalPosition, axist, angle);

	vec2 tuv = vec2(x/u_param,y/u_param);

	vec4 texture_heightmap = texture2D(u_height_map_texture, tuv.xy);
	float displacement = texture_heightmap.r;
	float height = displacement * u_displacement;
	finalPosition.y += height;

	v_uv_texture_debug = texture_heightmap.rgb * vec3(tuv.x * 0.5, 0.0, tuv.y*0.5);

	finalPosition += u_vertex_displacement; // custom displacement

	finalPosition.xz += vec2(
		final_noise + (x - width/2.0),
		final_noise + (y - dimension/2.0)
	);

	gl_PointSize = 1000.0;
	gl_Position = projectionMatrix * modelViewMatrix * vec4(finalPosition, 1.0);
}
