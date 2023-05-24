/*
 *  uniform mat4 projectionMatrix;
 *  uniform mat4 viewMatrix;
 *  uniform mat4 modelViewMatrix;
 *  uniform mat4 modelMatrix;
 *  attribute vec3 position;
*/ 

uniform float u_time;
attribute float angle;

attribute vec3 terrPosi;
varying vec2 vUv;

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

	vec3 finalPosition = position;
	finalPosition.x *= 0.7 * cos(uv.x);
	// finalPosition.x *= 0.7;
	finalPosition.y += 0.5;

	if(finalPosition.y > 0.5) {
		finalPosition.x = ( finalPosition.x + sin( u_time/10.0* ( angle*0.02 ) )  * 0.05);
		finalPosition.z = ( finalPosition.z + cos( u_time/10.0* ( angle*0.02 ) )  * 0.05);	
	}

	vec3 axist = vec3(0.0, 1.0, 0.0);
    finalPosition = rotate_vertex_position(finalPosition, axist, angle);

	finalPosition += terrPosi;

	// gl_PointSize = 100.0;
	gl_Position = projectionMatrix * modelViewMatrix * vec4(finalPosition, 1.0);
}