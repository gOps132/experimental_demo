import React from "react";
import * as THREE from "three";

import { grassShaderMaterial } from "./grass_shader_material";

import vertexShader from "./shaders/vertex_grass.glsl";
import fragmentShader from "./shaders/fragment_grass.glsl";

import { extend } from "@react-three/fiber";

// class GrassField extends THREE.Group {

// 	constructor() {
// 		// TODO: make these dynamic, probably use datgui
// 		super();
// 		console.log("start grass");

// 		this.instances = 10000;
// 		this.w = 10;
// 		this.d = 10;
// 		this.h = 0;

// 		this.vertices = [];
// 		this.indices = [];
// 		this.uvs = [];
		
// 		this.grassGeo;
// 		this.grassParticles;
// 		this.createParticles();
// 	}

// 	createParticles() {
// 		// square vertices, indices and uv coordinates
// 		this.vertices.push(1, -1, 0);
// 		this.vertices.push(-1, -1, 0);
// 		this.vertices.push(-1, 1, 0);
// 		this.vertices.push(1, 1, 0);

// 		this.indices.push(0);
// 		this.indices.push(1);
// 		this.indices.push(2);
// 		this.indices.push(2);
// 		this.indices.push(3);
// 		this.indices.push(0);

// 		this.uvs.push(1.0, 0.0);
// 		this.uvs.push(0.0, 0.0);
// 		this.uvs.push(0.0, 1.0);
// 		this.uvs.push(1.0, 1.0);

// 		for(let i = 0; i < this.instances; i++) {
			
// 		}

// 		this.grassGeo = new THREE.InstancedBufferGeometry();
// 		this.grassGeo.instanceCount =  this.instances;

// 		this.grassGeo.setAttribute('position', new THREE.Float32BufferAttribute(this.vertices));
// 		this.grassGeo.setAttribute('uv', new THREE.Float32BufferAttribute(this.uvs, 2));
// 		this.grassGeo.setIndex(new THREE.BufferAttribute(new Uint16Array(this.indices), 1));

// 		const grassMaterial = grassShaderMaterial(vertexShader, fragmentShader);

// 		this.grassParticles = new THREE.Mesh(this.grassGeo, grassMaterial);
// 		this.grassParticles.frustumCulled = false;

// 		this.add(this.grassParticles);
// 	}

// 	update(dt) {

// 	}
// }

function GrassFieldInstance() {
	let instances = 10000;
	let w = 10;
	let d = 10;
	let h = 0;

	let vertices = new Float32Array([
		1.0, -1.0, 0,
		-1.0, -1.0, 0,
		-1.0, 1.0, 0,
		1.0, 1.0, 0
	]);
	let uvs = new Float32Array([
		1.0, 0.0,
		0.0, 0.0,
		0.0, 1.0,
		1.0, 1.0
	]);
	let indices = new Uint16Array([0,1,2,2,3,0]);

	const uniforms = {}

	return (
		<group>
			<mesh
			>
				<instancedBufferGeometry
					instanceCount={instances}
				>
					<bufferAttribute
						attach={"attributes-position"}
						array={vertices}
						count={vertices.length / 3}
						itemSize={3}
					/>
					<bufferAttribute
						attach={"attributes-normal"}
						array={uvs}
						count={uvs.length / 2}
						itemSize={2}
					/>
					<bufferAttribute
						attach={"index"}
						array={indices}
						count={indices.length}
						itemSize={1}
					/>
				</instancedBufferGeometry>
				<shaderMaterial
					uniforms={uniforms}
					vertexShader={vertexShader}
					fragmentShader={fragmentShader}
					side={THREE.DoubleSide}
				/>
			</mesh>
		</group>
	);
}

export { GrassFieldInstance };