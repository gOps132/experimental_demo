import React, { useRef } from "react";
import * as THREE from "three";

import { useLoader, useFrame } from "@react-three/fiber";

import vertexShader from "./shaders/vertex_grass.glsl";
import fragmentShader from "./shaders/fragment_grass.glsl";

import { TextureLoader } from "three";

function GrassField() {
	const ref = useRef();

	const texture = useLoader(TextureLoader, "../textures/grass.jpg");
	const texture_02 = useLoader(TextureLoader, "../textures/grass_diffuse.jpg");

	let instances = 1000;
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
	let angles = [];

	const uniforms = {
		u_time : {
			type: "f",
			value: 0.0
		},
		grassMask: {
			value: texture
		},
		grassDiffuse: {
			value: texture_02
		},
		color1: {
			value: new THREE.Vector3(0.0, 255.0, 0.0)
		},
		color1: {
			value: new THREE.Vector3(0.0, 5.0, 0.0)
		}
	}

	useFrame(({clock}) => {
		const time = clock.getElapsedTime();
		// time.current += 0.03;
		ref.current.material.uniforms.u_time.value = time;
		// console.log(ref.current.material.uniforms.u_time.value);
	});

	for(let i = 0; i < instances; i++) {

		// let x = Math.random() * w - (w/2);
		let y = h;
		// let z = Math.random() * d - (d/2);

		let r = (w/2) || instances;
		var a = Math.random(),
			b = Math.random();
		
		if (w/2) {
			if (b < a) {
				let c = b;
				b = a;
				a = c;
			}
		}
		
		let x = b * r * Math.cos( 2 * Math.PI * a / b );
		let z = b * r * Math.sin( 2 * Math.PI * a / b );

		// x = y = z = 0;
		angles.push( Math.random()*360 );
		terrain_vertices.push(x,y,z)
	}

	console.log(angles);

	return (
		<group>
			<gridHelper args={[w,d]}/>
			<mesh ref={ref}>
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
						attach={"attributes-uv"}
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
					<instancedBufferAttribute
						attach={"attributes-angle"}
						array={new Float32Array(angles)}
						count={angles.length}
						itemSize={1}
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