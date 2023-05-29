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

	const grass_texture = useLoader(TextureLoader, "../textures/grass.jpg");
	const grass_diffuse_texture = useLoader(TextureLoader, "../textures/grass_diffuse.jpg");
	const dirt_texture = useLoader(TextureLoader, "../textures/dirt.jpg");
	
	dirt_texture.wrapS = dirt_texture.wrapT = THREE.RepeatWrapping;
    dirt_texture.offset.set( 0, 0 );
    dirt_texture.repeat.set( 20, 20 );

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
		// color: {value: '#1d5c11', onChange: (i) => {
		// 	grass_field.current.material.color.set(i)
		// }},
		reflectivity: 10.0,
	});

	const grass_params = useControls("Grass", {
		color1: {value: '#70cb5e', onChange: (i) => {
			grass_particles.current.material.uniforms.u_color1.value = new THREE.Color(i);
		}},
		color2: {value: '#000000', onChange: (i) => {
			grass_particles.current.material.uniforms.u_color2.value = new THREE.Color(i);
		}},
		noise_y: {value: 3.0, min: 0.0, max: 10.0, onChange: (i) => {
			grass_particles.current.material.uniforms.u_noise_y.value = i;
		}},
		noise_x: {value: 0.5, min: 0.0, max: 10.0, onChange: (i) => {
			grass_particles.current.material.uniforms.u_noise_x.value = i;
		}},	
		displacement: {value: [0.0,1.0,0.0], step: 0.05, onChange: (i) => {
			grass_particles.current.material.uniforms.u_displacement.value.x = i[0];
			grass_particles.current.material.uniforms.u_displacement.value.y = i[1];
			grass_particles.current.material.uniforms.u_displacement.value.z = i[2];
		}},	
	});

	const uniforms = THREE.UniformsUtils.merge([
		THREE.UniformsLib[ "lights" ],
		{
			u_displacement: {
				type: "f",
				value: new THREE.Vector3(0)
			},
			u_time : {
				type: "f",
				value: 0.0
			},
			u_noise_y : {
				type: "f",
				value: 1.0
			},
			u_noise_x : {
				type: "f",
				value: 1.0
			},
			grassMask: {
				type: "t",
				value: grass_texture
			},
			grassDiffuse: {
				type: "t",
				value: grass_diffuse_texture
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
	})
	return (
		<>
			<group>
				<mesh
					ref={grass_field}
					rotation={[(Math.PI / 2), 0, 0]}
				>
					<planeGeometry args={[w,d]}/> 
					<meshBasicMaterial
						{...plane_params}
						map={dirt_texture}
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