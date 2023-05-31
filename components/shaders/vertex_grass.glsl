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
attribute vec3 terrPosi;

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

// vec4 mod289(vec4 x){return x - floor(x * (1.0 / 289.0)) * 289.0;}
// vec4 perm(vec4 x){return mod289(((x * 34.0) + 1.0) * x);}

// float noise(vec3 p){
// 	vec3 a = floor(p);
// 	vec3 d = p - a;
// 	d = d * d * (3.0 - 2.0 * d);

// 	vec4 b = a.xxyy + vec4(0.0, 1.0, 0.0, 1.0);
// 	vec4 k1 = perm(b.xyxy);
// 	vec4 k2 = perm(k1.xyxy + b.zzww);

// 	vec4 c = k2 + a.zzzz;
// 	vec4 k3 = perm(c);
// 	vec4 k4 = perm(c + 1.0);

// 	vec4 o1 = fract(k3 * (1.0 / 41.0));
// 	vec4 o2 = fract(k4 * (1.0 / 41.0));

// 	vec4 o3 = o2 * d.z + o1 * (1.0 - d.z);
// 	vec2 o4 = o3.yw * d.x + o3.xz * (1.0 - d.x);

// 	return o4.y * d.y + o4.x * (1.0 - d.y);
// }

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

	/* TODO:
		add noise to height of each grass from += -0.5
		to += 1.5 for more variety
	*/
	finalPosition.y += 0.5;

	finalPosition.xy *= vec2(u_posy, u_posx);
	// finalPosition.xy *= vec2(u_posy, instance + u_posx);
	// finalPosition.xyz *= abs(terrPosi.y);

	// noise function noise(x,y,u_time), use the resolution of the canvas 
	// or for example 100x100 according to the value of the instance, which is the only
	// none constant variable, make a mathematical formula for getting x,y coordinates within 
	// 100x100 according to instance
	// variable which iterates over 0->10000 

	// x = (w / max instance) * instance
	// y = (d / max instance) * instance

	// float x = mod(v_instance,100.0);
	// float y = mod((v_instance / 100.0), 100.0);

	float x = mod(v_instance,width);
	float y = mod((v_instance / dimension), dimension);

	// float x = mod(v_instance,width);
	// float y = v_instance / dimension;

	// float _noise_cache = noise(vec3(x,y,u_time));
	// float _noise_cache = noise(vec3(x,y,0.0));
	// float _noise_cache = noise(vec3(x,y,0.0));

	// float _noise_cache = snoise(vec2(x,y)*u_noise); //use this
	float _noise_cache = snoise(vec2(x,y)*u_time*0.005);
	// float _noise_cache = snoise(vec2(x,y)*(cos((u_time)))*u_noise);

	finalPosition.xy *= _noise_cache;

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

	// finalPosition.xz += vec2(
	// 	((_noise_cache) * -x)+width /2.0,
	// 	((_noise_cache) * -y) + dimension /2.0
	// );

	finalPosition.xz += vec2(
		(_noise_cache+x)-width/2.0,
		(_noise_cache+y)-dimension/2.0
	);

	// finalPosition.xz += terrPosi.xz;

	gl_PointSize = 1000.0;
	gl_Position = projectionMatrix * modelViewMatrix * vec4(finalPosition, 1.0);
}
