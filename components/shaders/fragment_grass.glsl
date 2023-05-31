// really helps
// https://www.youtube.com/watch?v=e-lnyzN2wrM

// from: http://lolengine.net/blog/2013/07/27/rgb-to-hsv-in-glsl

precision mediump float;

uniform vec3 u_color1;
uniform vec3 u_color2;
uniform vec3 ambientLightColor;

uniform float v_time;
varying vec2 vUv;
varying vec3 v_normal;
flat varying float v_instance;

#if NUM_DIR_LIGHTS > 0
	struct DirectionalLight {
		vec3 direction;
		vec3 color;
	};

	uniform DirectionalLight directionalLights[ NUM_DIR_LIGHTS ];
#endif

vec3 rgb2hsv(vec3 c) {
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
	vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c) {
	c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {
	// vec3 mixed_color = mix(u_color2, u_color1, vUv.y);

	// TODO: fix lighting
	// transform directional light into local space?
	// lambert rule, gives cosine of angle between the surface normal and the light direction
	float diffuse_factor = dot(normalize(v_normal), -directionalLights[0].direction);

	vec3 diffuse_color = directionalLights[0].color;
	// vec3 diffuse_color = vec3(0.0, 0.0, 0.0);

	if (diffuse_factor > 0.0) {
		diffuse_color = 
			diffuse_color * 
			// intensity *
			diffuse_factor;
	}

	vec3 hsv1 = rgb2hsv(u_color1);
	vec3 hsv2 = rgb2hsv(u_color2);
	
	float hue = (mod(mod((hsv2.x - hsv1.x), 1.) + 1.5, 1.) - 0.5) * vUv.y + hsv1.x;
	vec3 hsv = vec3(hue, mix(hsv2.yz, hsv1.yz, vUv.y));

	// color1 -> color2 -> ambient occlusion
	// vec3 mixed_color = hsv2rgb(hsv);
	vec3 mixed_color = mix(ambientLightColor, hsv2rgb(hsv), vUv.y);

	gl_FragColor = vec4(
		mixed_color
		* diffuse_color,
		1);
}