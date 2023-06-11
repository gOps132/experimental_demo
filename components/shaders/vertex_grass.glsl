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
uniform vec2 u_offset;
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

varying vec3 v_uv_texture_debug;

// float is just for annoying type conversiodns
flat varying float v_instance;

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

void main() {
	v_time = u_time;
	vUv = uv;
	v_normal = normal;
	v_instance = float(gl_InstanceID);
	
	float width = float(u_dimensions.x);
	float dimension = float(u_dimensions.y);

	vec3 finalPosition = position;

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

	// float x = mod(v_instance,width);
	// float y =  mod((v_instance / dimension), width);

	// float y = dimension/2.0 - floor(v_instance / width);

	float noise_cache = snoise(vec2(x,y));
	float final_noise = snoise(vec2(x,y) * (u_animate ? ((cos((u_time*0.5)))*u_noise) : u_noise));

	// x *= noise_cache;
	// y *= noise_cache;

	float angle = noise_cache * 360.0;

	// assign positions
	// ===========================================
	// finalPosition.xz = vec2(x, y - float(dimension) * 0.5) * (1.0f / float(1));
	// finalPosition.x += snoise(vec2(x,y) * 3.0) * 0.2;
	// finalPosition.y += snoise(vec2(x, finalPosition.z) * 4.0) * 0.2;

	finalPosition.y += 0.5;

	// TODO:
	// the smaller the blade, the thinner it looks
	// so height is directly proportional to width
	// the lower the posx the thinner
	// the higher the posy the higher 
	// x = 1/y
	// the noise should not be independent from the value of x and y
	//	x = (y * z) / z
	// y = z/x

	finalPosition.xy *= vec2(u_posx, u_posy);
	// finalPosition.xy *= vec2(u_posx, u_posy) * abs(noise_cache);
	// finalPosition.xy *= vec2((1.0/u_posx),u_posy) * abs(noise_cache); //works but no noise
	// finalPosition.xy *= vec2((u_posx * abs(noise_cache)),abs(noise_cache)/u_posy);
	// finalPosition.yz *= abs(final_noise);

	// grass sway
	if(finalPosition.y > 0.5) {
		finalPosition.x = ( finalPosition.x + sin( u_time/0.5* ( angle*0.01 ) )  * u_amplitude);
		finalPosition.z = ( finalPosition.z + cos( u_time/0.5* ( angle*0.01 ) )  * u_amplitude);	
	}

	vec3 axist = vec3(0.0, 0.5, 0.0); // grass rotation
	finalPosition = rotate_vertex_position(finalPosition, axist, angle);

	// converting the worldspace coordinates of the grass to uv coordinates

	// vec2 tuv = (finalPosition.xy/finalPosition.z);
	// vec4 texture_heightmap = texture2D(u_height_map_texture, tuv);
	// vec3 deform = texture_heightmap.rgb * finalPosition.z; // unprojected heightmap into worldspace
	// vec2 tex_coord = vec2(uv.x, uv.y);
	// vec4 deform = texture2D(u_height_map_texture, tex_coord);
    // vec3 displacement = deform.rgb * u_displacement;
    // finalPosition.y += abs((texture_heightmap.rgb * u_displacement).y);
    // finalPosition.y += (deform.rgb * u_displacement).y;
	// finalPosition = finalPosition + normal * displacement;

	// height map scale 
	// vSamplePos = bladePos.xy * heightMapScale.xy + vec2(0.5, 0.5);
	// vec2 sample_pos = vec2(x,y) *  

	// vec2 tuv = uv;
	// vec2 tuv = vec2(finalPosition.x/u_param,finalPosition.y/u_param);
	// vec2 tuv = vec2(x/u_param,y/u_param) * vec2(1081, 1081);

	vec2 tuv = vec2(x/u_param,y/u_param);
	
	// tuv = tuv * (1.0/1081.0);	
	// tuv /= 300.0 * (1.0/1081.0);
	// tuv.x = 1.0 - tuv.x;
	// tuv.y = 1.0 - tuv.y;
	// vec2 tuv = vec2(x,y) / vec2(u_param,u_param);
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
