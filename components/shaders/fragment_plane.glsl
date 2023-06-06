precision mediump float;

// just a sample
uniform sampler2D u_height_map_texture;
varying vec2 vUv;

void main() {
    vec4 sample_tex = texture2D(u_height_map_texture, vUv);
    // gl_FragColor = vec4(0.45f, 0.3f, 0.17f, 1.0f);
    gl_FragColor = sample_tex;
}