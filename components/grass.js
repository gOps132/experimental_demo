import React, { useEffect, useMemo, useRef, useState } from "react";
import * as THREE from "three";

import { useLoader, useFrame, extend } from "@react-three/fiber";

import vertexShader from "./shaders/vertex_grass.glsl";
import fragmentShader from "./shaders/fragment_grass.glsl";

import { TextureLoader } from "three";
import { COOKIE_NAME_PRERENDER_BYPASS } from "next/dist/server/api-utils";

function GrassField() {
	const grass_field = useRef();
	const grass_particles = useRef();

	const texture = useLoader(TextureLoader, "../textures/grass.jpg");
	const texture_02 = useLoader(TextureLoader, "../textures/grass_diffuse.jpg");

	let instances = 10000;
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

	let color_params = {
		color1: 0x50000,
		color2: 0x10105,
	}

	const uniforms = THREE.UniformsUtils.merge([
		THREE.UniformsLib[ "lights" ],
		{
			u_time : {
				type: "f",
				value: 0.0
			},
			grassMask: {
				type: "t",
				value: texture
			},
			grassDiffuse: {
				type: "t",
				value: texture_02
			},
			u_color1: {
				type: "i",
				value: color_params.color1
			},
			u_color2: {
				type: "i",
				value: color_params.color2
			},
		}
	]);

	useEffect(() => {
		console.log(uniforms);
		// console.log(grass_particles.current);

		import("dat.gui").then(({ GUI }) => {
			const gui = new GUI();
			const grassFieldFolder = gui.addFolder("grass field");
			grassFieldFolder.addColor(color_params, "color1").onChange((i) => {
				grass_field.current.material.color.set(color_params.color1)
			})
			// grassFieldFolder.add(grass_field.current.rotation, 'x', 0, Math.PI)
			// 	.name("Grass Rotation");
			const grassFieldColor = gui.addFolder("grass color");
			grassFieldColor.addColor(color_params, "color1").onChange((i) => {
				grass_particles.current.material.uniforms.u_color1.value = i;
			})
			grassFieldColor.addColor(color_params, "color2").onChange((i) => {
				grass_particles.current.material.uniforms.u_color2.value = i;
			})
		})
	})

	useFrame((state) => {
		const { clock } = state;
		grass_particles.current.material.uniforms.u_time.value = clock.getElapsedTime();
		// console.log(grass_particles.current.material.uniforms.u_time.value);
	});

	// grass placement
	for(let i = 0; i < instances; i++) {
		// let r = (w/2) || instances;
		// var a = Math.random(),
		// 	b = Math.random();
		// if (w/2) {
		// 	if (b < a) {
		// 		let c = b;
		// 		b = a;
		// 		a = c;
		// 	}
		// }
		// let x = b * r * Math.cos( 2 * Math.PI * a / b );
		// let z = b * r * Math.sin( 2 * Math.PI * a / b );

		let y = h;

		let x = Math.random() * w - (w/2);
		let z = Math.random() * d - (d/2);

		// x = y = z = 0;
		angles.push( Math.random()*360 );
		terrain_vertices.push(x,y,z)
	}

	return (
		<>
			<group>
				<gridHelper args={[w,d]}/>
				<mesh
					ref={grass_field}
					rotation={[(Math.PI / 2), 0, 0]}
				>
					<planeGeometry args={[w,d]}/> 
					<meshBasicMaterial
							color={0x6570c}
							side={THREE.DoubleSide}
					/>
				</mesh>
				<mesh ref={grass_particles}>
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
						lights={true}
						side={THREE.DoubleSide}
					/>
				</mesh>
			</group>
		</>
	);
}

export { GrassField };