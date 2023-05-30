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

uniform float u_time;
attribute float angle;
attribute vec3 terrPosi;

uniform float u_posy;
uniform float u_posx;
uniform vec3 u_displacement;

varying vec2 vUv;
varying vec3 v_normal;

vec4 mod289(vec4 x){return x - floor(x * (1.0 / 289.0)) * 289.0;}
vec4 perm(vec4 x){return mod289(((x * 34.0) + 1.0) * x);}

float noise(vec3 p){
	vec3 a = floor(p);
	vec3 d = p - a;
	d = d * d * (3.0 - 2.0 * d);

	vec4 b = a.xxyy + vec4(0.0, 1.0, 0.0, 1.0);
	vec4 k1 = perm(b.xyxy);
	vec4 k2 = perm(k1.xyxy + b.zzww);

	vec4 c = k2 + a.zzzz;
	vec4 k3 = perm(c);
	vec4 k4 = perm(c + 1.0);

	vec4 o1 = fract(k3 * (1.0 / 41.0));
	vec4 o2 = fract(k4 * (1.0 / 41.0));

	vec4 o3 = o2 * d.z + o1 * (1.0 - d.z);
	vec2 o4 = o3.yw * d.x + o3.xz * (1.0 - d.x);

	return o4.y * d.y + o4.x * (1.0 - d.y);
}

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
	vUv = uv;
	v_normal = normal;
	
	vec3 finalPosition = position;
	// finalPosition.x *= 0.7 * cos(uv.x);

	/* TODO:
		add noise to height of each grass from += -0.5
		to += 1.5 for more variety
	*/
	
	finalPosition.xy *= vec2(u_posy, u_posx);

	
	// finalPosition.y += snoise(vec2(finalPosition.x, u_time));

	finalPosition += u_displacement;
	
	if(finalPosition.y > 0.5) {
		finalPosition.x = ( finalPosition.x + sin( u_time/0.5* ( angle*0.01 ) )  * 0.05);
		finalPosition.z = ( finalPosition.z + cos( u_time/0.5* ( angle*0.01 ) )  * 0.05);	
	}

	vec3 axist = vec3(0.0, 0.5, 0.0);
	finalPosition = rotate_vertex_position(finalPosition, axist, angle);

	finalPosition += terrPosi;

	gl_PointSize = 1000.0;

	// how to make instancing work on individual instances without having attributes or
	// uniforms
	// #ifdef USE_INSTANCING
		// Note that modelViewMatrix is not set when rendering an instanced model,
		// but can be calculated from viewMatrix * modelMatrix.
		//
		// Basic Usage:
		// attribute mat4 instanceMatrix;
		// gl_Position = projectionMatrix * viewMatrix * modelMatrix * instanceMatrix * vec4(finalPosition, 1.0);
	// #endif

	gl_Position = projectionMatrix * modelViewMatrix * vec4(finalPosition, 1.0);
}

