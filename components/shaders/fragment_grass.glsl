/*
void main() {
	gl_FragColor = vec4( 1.0, 0.0, 0.0, 1.0 );
}
*/

// /*
precision mediump float;

// uniform int u_color1;
// uniform int u_color2;

uniform vec3 u_color1;
uniform vec3 u_color2;


uniform sampler2D grassMask;
uniform sampler2D grassDiffuse;

varying vec2 vUv;

// float modI(float a, float b);

// vec3 convert_color(int r_color) {
// 	// float temp = modI(256.0,256.0);
//     float r_int_val = modI(float(r_color / 256 / 256), 256.0);
//     float g_int_val = modI(float(r_color / 256), 256.0);
//     float b_int_val = modI(float(r_color), 256.0);

// 	return vec3(r_int_val, g_int_val, b_int_val); 
// }

// float modI(float a,float b) {
//     float m=a-floor((a+0.5)/b)*b;
//     return floor(m+0.5);
// }

void main() {
	vec2 st = gl_PointCoord;
	float mixValue = distance(st, vec2(0, 1));

	// vec3 color1 = convert_color(u_color1);
	// vec3 color2 = convert_color(u_color2);

	vec3 maskColor = texture2D(grassMask, vUv).rgb;

	// vec3 mixColor = color1;
	vec3 mixColor = mix(u_color1, u_color2, mixValue).rgb;

	// vec3 finalColor = texture2D(grassDiffuse, vUv).rgb;

	vec3 diffuseTexture = texture2D(grassDiffuse, vUv).rgb;
	vec3 finalColor = diffuseTexture * mixColor;

	gl_FragColor = vec4(finalColor, 1);
	
	if (maskColor.r <= 0.5) {
		discard;
	}
}
// */

/*
precision mediump float;

uniform vec3 color1;
uniform vec3 color2;

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
	float mixValue = distance(st, vec2(0, 1));

	vec3 hsv1 = rgb2hsv(color1);
	vec3 hsv2 = rgb2hsv(color2);
	
	// mix hue in toward closest direction
	float hue = (mod(mod((hsv2.x - hsv1.x), 1.) + 1.5, 1.) - 0.5) * mixValue + hsv1.x;
	vec3 hsv = vec3(hue, mix(hsv1.yz, hsv2.yz, mixValue));
	
	vec3 color = hsv2rgb(hsv);
		
	gl_FragColor = vec4(color, 1);
}
*/



/*
precision mediump float;

uniform vec3 color1;
uniform vec3 color2;

// from: https://code.google.com/archive/p/flowabs/source

vec3 rgb2xyz( vec3 c ) {
	vec3 tmp;
	tmp.x = ( c.r > 0.04045 ) ? pow( ( c.r + 0.055 ) / 1.055, 2.4 ) : c.r / 12.92;
	tmp.y = ( c.g > 0.04045 ) ? pow( ( c.g + 0.055 ) / 1.055, 2.4 ) : c.g / 12.92,
	tmp.z = ( c.b > 0.04045 ) ? pow( ( c.b + 0.055 ) / 1.055, 2.4 ) : c.b / 12.92;
	return 100.0 * tmp *
		mat3( 0.4124, 0.3576, 0.1805,
			  0.2126, 0.7152, 0.0722,
			  0.0193, 0.1192, 0.9505 );
}

vec3 xyz2lab( vec3 c ) {
	vec3 n = c / vec3( 95.047, 100, 108.883 );
	vec3 v;
	v.x = ( n.x > 0.008856 ) ? pow( n.x, 1.0 / 3.0 ) : ( 7.787 * n.x ) + ( 16.0 / 116.0 );
	v.y = ( n.y > 0.008856 ) ? pow( n.y, 1.0 / 3.0 ) : ( 7.787 * n.y ) + ( 16.0 / 116.0 );
	v.z = ( n.z > 0.008856 ) ? pow( n.z, 1.0 / 3.0 ) : ( 7.787 * n.z ) + ( 16.0 / 116.0 );
	return vec3(( 116.0 * v.y ) - 16.0, 500.0 * ( v.x - v.y ), 200.0 * ( v.y - v.z ));
}

vec3 rgb2lab(vec3 c) {
	vec3 lab = xyz2lab( rgb2xyz( c ) );
	return vec3( lab.x / 100.0, 0.5 + 0.5 * ( lab.y / 127.0 ), 0.5 + 0.5 * ( lab.z / 127.0 ));
}


vec3 lab2xyz( vec3 c ) {
	float fy = ( c.x + 16.0 ) / 116.0;
	float fx = c.y / 500.0 + fy;
	float fz = fy - c.z / 200.0;
	return vec3(
		 95.047 * (( fx > 0.206897 ) ? fx * fx * fx : ( fx - 16.0 / 116.0 ) / 7.787),
		100.000 * (( fy > 0.206897 ) ? fy * fy * fy : ( fy - 16.0 / 116.0 ) / 7.787),
		108.883 * (( fz > 0.206897 ) ? fz * fz * fz : ( fz - 16.0 / 116.0 ) / 7.787)
	);
}

vec3 xyz2rgb( vec3 c ) {
	vec3 v =  c / 100.0 * mat3( 
		3.2406, -1.5372, -0.4986,
		-0.9689, 1.8758, 0.0415,
		0.0557, -0.2040, 1.0570
	);
	vec3 r;
	r.x = ( v.r > 0.0031308 ) ? (( 1.055 * pow( v.r, ( 1.0 / 2.4 ))) - 0.055 ) : 12.92 * v.r;
	r.y = ( v.g > 0.0031308 ) ? (( 1.055 * pow( v.g, ( 1.0 / 2.4 ))) - 0.055 ) : 12.92 * v.g;
	r.z = ( v.b > 0.0031308 ) ? (( 1.055 * pow( v.b, ( 1.0 / 2.4 ))) - 0.055 ) : 12.92 * v.b;
	return r;
}

vec3 lab2rgb(vec3 c) {
	return xyz2rgb( lab2xyz( vec3(100.0 * c.x, 2.0 * 127.0 * (c.y - 0.5), 2.0 * 127.0 * (c.z - 0.5)) ) );
}

void main() {
  vec2 st = gl_PointCoord;
  float mixValue = distance(st, vec2(0, 1));

  vec3 lab1 = rgb2lab(color1);
  vec3 lab2 = rgb2lab(color2);
	
  vec3 lab = mix(lab1, lab2, mixValue);
  
  vec3 color = lab2rgb(lab);
	
  gl_FragColor = vec4(color, 1);
}
*/