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

attribute float angle;

uniform float u_time;
uniform float u_amplitude;
uniform float u_posy;
uniform float u_posx;
uniform vec3 u_displacement;
uniform vec2 u_dimensions;
uniform float u_noise;

varying vec2 vUv;
varying vec3 v_normal;
varying float v_time;

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

	finalPosition.y += 0.5;

	finalPosition.xy *= vec2(u_posy, u_posx);

	// noise function noise(x,y,u_time), use the resolution of the canvas 
	// or for example 100x100 according to the value of the instance, which is the only
	// none constant variable, make a mathematical formula for getting x,y coordinates within 
	// 100x100 according to instance
	// variable which iterates over 0->10000 

	float x = width/2.0 - mod(v_instance,width);
	float y = dimension/2.0 - mod((v_instance / dimension), dimension);

	float _noise_cache = snoise(vec2(x,y)*u_noise); //use this
	// float _noise_cache = snoise(vec2(x,y)*u_time*0.005);
	// float _noise_cache = snoise(vec2(x,y)*(cos((u_time)))*u_noise);

	finalPosition.xy *= abs(_noise_cache);

	finalPosition += u_displacement;

	if(finalPosition.y > 0.5) {
		finalPosition.x = ( finalPosition.x + sin( u_time/0.5* ( angle*0.01 ) )  * u_amplitude);
		finalPosition.z = ( finalPosition.z + cos( u_time/0.5* ( angle*0.01 ) )  * u_amplitude);	
	}

	vec3 axist = vec3(0.0, 0.5, 0.0);
	finalPosition = rotate_vertex_position(finalPosition, axist, angle);

	// linear graph
	// finalPosition.xz += vec2(
	// 	(abs(_noise_cache) * width)-(width/2.0),
	// 	(abs(_noise_cache) * dimension)-(dimension/2.0)
	// );

	// cool function
	// finalPosition.xz += vec2(
	// 	(_noise_cache) * x - x/2.0,
	// 	(_noise_cache) * y - y/2.0
	// );

	finalPosition.xz += vec2(
		(_noise_cache+x),
		(_noise_cache+y)
	);

	gl_PointSize = 1000.0;
	gl_Position = projectionMatrix * modelViewMatrix * vec4(finalPosition, 1.0);
}
