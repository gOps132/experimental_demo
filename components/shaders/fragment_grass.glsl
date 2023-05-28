precision mediump float;

uniform vec3 u_color1;
uniform vec3 u_color2;

uniform sampler2D grassMask;
uniform sampler2D grassDiffuse;

varying vec2 vUv;

uniform vec3 ambientLightColor;

// from: http://lolengine.net/blog/2013/07/27/rgb-to-hsv-in-glsl

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
	vec2 st = gl_PointCoord;
	float mixValue = distance(st, vec2(0, 0.5));
	vec3 maskColor = texture2D(grassMask, vUv).rgb;
	vec3 diffuseTexture = texture2D(grassDiffuse, vUv).rgb;

	vec3 hsv1 = rgb2hsv(u_color1);
	vec3 hsv2 = rgb2hsv(u_color2);
	
	// mix hue in toward closest direction
	float hue = (mod(mod((hsv2.x - hsv1.x), 1.) + 1.5, 1.) - 0.5) * mixValue + hsv1.x;
	vec3 hsv = vec3(hue, mix(hsv1.yz, hsv2.yz, mixValue));
	
	vec3 color = hsv2rgb(hsv);

	// gl_FragColor = vec4((color * diffuseTexture), 1);
	gl_FragColor = vec4((color * diffuseTexture) * ambientLightColor, 1);
	// gl_FragColor = vec4(color * ambientLightColor, 1);
	// gl_FragColor = vec4(color, 1);

	if (maskColor.r <= 0.5) {
		discard;
	}
}