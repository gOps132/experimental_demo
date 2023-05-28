import React, { useEffect, useMemo, useRef, useState } from "react";
import * as THREE from "three";

import { useLoader, useFrame, extend } from "@react-three/fiber";

import vertexShader from "./shaders/vertex_grass.glsl";
import fragmentShader from "./shaders/fragment_grass.glsl";

import { TextureLoader } from "three";

import { useControls } from "leva";

THREE.MeshMatcapMaterial;

function GrassField(props) {
	const grass_field = useRef();
	const grass_particles = useRef();

	const texture = useLoader(TextureLoader, "../textures/grass.jpg");
	const texture_02 = useLoader(TextureLoader, "../textures/grass_diffuse.jpg");

	let instances = props.instances ? props.instances : 10000;
	let w = props.width ? props.width : 20;
	let d = props.dimension ? props.dimension : 20;
	let h = props.height ?  props.height : 0;

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

	let terrain_vertices = [];
	let angles = [];


	const plane_params = useControls("Grass Plane", {
		color: {value: '#1d5c11', onChange: (i) => {
			grass_field.current.material.color.set(i)
		}},
	});

	const grass_params = useControls("Grass", {
		color1: {value: '#2afc00', onChange: (i) => {
			grass_particles.current.material.uniforms.u_color1.value = new THREE.Color(i);
		}},
		color2: {value: '#044b00', onChange: (i) => {
			grass_particles.current.material.uniforms.u_color2.value = new THREE.Color(i);
		}},	
	});

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
				value: new  THREE.Color(grass_params.color1)
			},
			u_color2: {
				type: "i",
				value: new THREE.Color(grass_params.color2)
			},
		}
	]);
	
	useFrame((state) => {
		const { clock } = state;
		grass_particles.current.material.uniforms.u_time.value = clock.getElapsedTime();
		// console.log(grass_particles.current.material.uniforms.u_time.value);
	});

	// grass placement
	for(let i = 0; i < instances; i++) {

		// round 
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
		// let x = b * r * Math.cos( 2 * Math.PI * a / b );
		// let z = b * r * Math.sin( 2 * Math.PI * a / b );

		// square
		let x = Math.random() * w - (w/2);
		let z = Math.random() * d - (d/2);

		let y = h;

		// x = y = z = 0;
		angles.push( Math.random()*360 );
		terrain_vertices.push(x,y,z)
	}

	useEffect(() => {
		console.log(uniforms);
		// console.log(
		// 	THREE.ShaderChunk.aomap_fragment +
		// 	THREE.ShaderChunk.aomap_pars_fragment +
		// 	fragmentShader);
	})
	return (
		<>
			<group>
				{/* <gridHelper args={[w,d]}/> */}
				<mesh
					ref={grass_field}
					rotation={[(Math.PI / 2), 0, 0]}
				>
					<planeGeometry args={[w,d]}/> 
					<meshBasicMaterial
						{...plane_params}
						side={THREE.DoubleSide}
					/>
				</mesh>
				<mesh ref={grass_particles}>
					{/* TODO: draw range of these should be dynamic */}
					<instancedBufferGeometry
						// setDrawRange={[
						// 	0,
						// 	terrain_vertices.length / 3
						// ]} 
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
						vertexShader={
							vertexShader
						}
						fragmentShader={
							fragmentShader
						}
						lights={true}
						side={THREE.DoubleSide}
					/>
				</mesh>
			</group>
		</>
	);
}

export { GrassField };