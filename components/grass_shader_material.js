
import * as THREE from "three";

function grassShaderMaterial(vertex_shader, fragment_shader) {
    const uniforms = {

    };

    const basicShaderMaterial = new THREE.RawShaderMaterial({
        uniforms: uniforms,
        vertexShader: vertex_shader,
        fragmentShader: fragment_shader,
        
        side: THREE.DoubleSide,
        // blending: THREE.AdditiveBlending,
    });

    return basicShaderMaterial;
}

export {grassShaderMaterial};