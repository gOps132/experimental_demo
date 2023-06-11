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

precision mediump float;

uniform sampler2D u_height_map_texture;
uniform float u_displacement;

varying vec2 vUv; 
varying vec3 vNormal;

void main() {
    vUv = uv;
    vNormal = normal;

    vec4 deform = texture2D(u_height_map_texture, uv);
    float displacement = deform.r * u_displacement;

    vec3 newPosition = position + normal * -displacement;

    vec4 modelViewPosition = modelViewMatrix * vec4(newPosition, 1.0);
    gl_Position = projectionMatrix * modelViewPosition;
}