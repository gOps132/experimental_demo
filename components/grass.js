import React from "react";
import * as THREE from "three";

import vertexShader from "./shaders/vertex_grass.glsl";
import fragmentShader from "./shaders/fragment_grass.glsl";

function GrassField() {
	let instances = 2000;
	let w = 20;
	let d = 20;
	let h = 0;

	let vertices = new Float32Array([
		0.5, -0.5, 0,
		-0.5, -0.5, 0,
		-0.5, 0.5, 0,
		0.5, 0.5, 0
	]);
	let uvs = new Float32Array([
		1.0, 0.0,
		0.0, 0.0,
		0.0, 1.0,
		1.0, 1.0
	]);
	let indices = new Uint16Array([0,1,2,2,3,0]);

	let terrain_vertices = [];
	const uniforms = {}

	for(let i = 0; i < instances; i++) {
		let x = Math.random() * w - (w/2);
		let y = h;
		let z = Math.random() * d - (d/2);

		terrain_vertices.push(x,y,z)
	}

	console.log(terrain_vertices);

	return (
		<group>
			<gridHelper args={[w,d]}/>
			<mesh>
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
					<instancedBufferAttribute
						attach={"attributes-terrPosi"}
						array={new Float32Array(terrain_vertices)}
						count={terrain_vertices.length / 3}
						itemSize={3}
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

export { GrassField };