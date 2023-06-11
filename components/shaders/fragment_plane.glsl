precision mediump float;

// uniform vec3 ambientLightColor;
// #if NUM_DIR_LIGHTS > 0
// 	struct DirectionalLight {
// 		vec3 direction;
// 		vec3 color;
// 	};

// 	uniform DirectionalLight directionalLights[ NUM_DIR_LIGHTS ];
// #endif

uniform sampler2D u_height_map_texture;
uniform sampler2D u_dirt_texture;

varying vec2 vUv;
varying vec3 vNormal;

void main() {
    // float diffuse_factor = dot(normalize(vNormal), -directionalLights[0].direction);
	// vec3 diffuse_color = directionalLights[0].color;

	// if (diffuse_factor > 0.0) {
	// 	diffuse_color = diffuse_color * diffuse_factor;
	// }

    vec4 sample_tex = texture2D(u_height_map_texture, vUv);
    vec4 dirt_tex = texture2D(u_dirt_texture, vUv);

    vec3 final_texture = sample_tex.rgb * dirt_tex.rgb;

    // visulization, red to blue
    // vec3 final_texture = sample_tex.rgb * vec3(vUv.x * 0.5, 0.0, vUv.y*0.5);

    gl_FragColor = vec4(final_texture,1.0);
    // gl_FragColor = vec4(0.45f, 0.3f, 0.17f, 1.0f);
}