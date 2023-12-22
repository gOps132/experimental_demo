import React, { useEffect, useMemo, useRef, useState } from "react";
import * as THREE from "three";

import { useLoader, useFrame, extend } from "@react-three/fiber";

import simplex from "./shaders/simplex.glsl";

import grassVertexShader from "./shaders/vertex_grass.glsl";
import grassFragmentShader from "./shaders/fragment_grass.glsl";

import planeVertexShader from "./shaders/vertex_plane.glsl";
import planeFragmentShader from "./shaders/fragment_plane.glsl";

import { TextureLoader } from "three";

import { useControls } from "leva";
import { ComputedAttribute } from "@react-three/drei";

function GrassField(props) {
	const plane_ref = useRef();
	const grass_ref = useRef();

	const dirt_texture = useLoader(TextureLoader, "../textures/dirt_02.png");
	const height_map = useLoader(TextureLoader, "../textures/height_map_01.png");

	dirt_texture.wrapS = dirt_texture.wrapT = THREE.RepeatWrapping;
    dirt_texture.offset.set( 0, 0 );
    dirt_texture.repeat.set( 40, 40 )
	

	let w = props.width ? props.width : 20;
	let d = props.dimension ? props.dimension : 20;
	 
	// TODO: add a density slider to calculate the density of each "chunk"
	// 
	let instances = (w * d);

	// simple triangle
	let vertices = new Float32Array([
		-0.5, -0.5, 0.0,
		0.0,  0.5, 0.0,
		0.5,  -0.5, 0.0,
	]);
	let uvs = new Float32Array([
		0.0, 0.0,
		1.0, 1.0,
		1.0, 0.0,
		1.0, 1.0
	]);
	const normals = new Float32Array([
		0, 0, 1,
		0, 0, 1,
		0, 0, 1,
		0, 0, 1,
	]);
	let indices = new Uint16Array([0,1,2]);

	const plane_params = useControls("Grass Plane", {
		// dimensions: {value: [w,d], step: 1.00, onChange: (i) => {
		// 	grass_ref.current.material.uniforms.u_dimensions.value.x = i[0];
		// 	grass_ref.current.material.uniforms.u_dimensions.value.y = i[1];
		// }},
		displacement: {value: 1.0, step: 1.0, onChange: (i) => {
			plane_ref.current.material.uniforms.u_displacement.value = i;
			grass_ref.current.material.uniforms.u_displacement.value = i;
		}},
	});

	const plane_uniforms =  THREE.UniformsUtils.merge([
		THREE.UniformsLib['lights'], {
			u_displacement : {
				type: "f",
				value: 1.0,
			},
			u_height_map_texture : {
				value: height_map
			},
			u_dirt_texture : {
				value: dirt_texture
			}
	}]);

	const grass_params = useControls("Grass", {
		u_param : {value: 300.0, step: 10.0, onChange: (i) => {
			grass_ref.current.material.uniforms.u_param.value = i;
		}},
		animation: {value: false, onChange: (i) => {
			grass_ref.current.material.uniforms.u_animate.value = i;
		}},
		color1: {value: '#413709', onChange: (i) => {
			grass_ref.current.material.uniforms.u_color1.value = new THREE.Color(i);
		}},
		color2: {value: '#0ac100', onChange: (i) => {
			grass_ref.current.material.uniforms.u_color2.value = new THREE.Color(i);
		}},
		posy: {value: 10.0, min: 0.0, step: 0.01, max: 10.0, onChange: (i) => {
			grass_ref.current.material.uniforms.u_posy.value = i;
		}},
		posx: {value: 0.25, min: 0.0, step: 0.01,max: 10.0, onChange: (i) => {
			grass_ref.current.material.uniforms.u_posx.value = i;
		}},
		noise: {value: 0.30, min: 0.00, max: 1.0, onChange: (i) => {
			grass_ref.current.material.uniforms.u_noise.value = i;
		}},
		amplitude: {value: 0.05, min: 0.00, max: 1.0, onChange: (i) => {
			grass_ref.current.material.uniforms.u_amplitude.value = i;
		}},
		displacement: {value: [0.0,0.0,0.0], step: 0.05, onChange: (i) => {
			grass_ref.current.material.uniforms.u_vertex_displacement.value.x = i[0];
			grass_ref.current.material.uniforms.u_vertex_displacement.value.y = i[1];
			grass_ref.current.material.uniforms.u_vertex_displacement.value.z = i[2];
		}},
	});

	const grassUniforms = THREE.UniformsUtils.merge([
		THREE.UniformsLib[ "lights" ], {
			u_height_map_texture : {
				value: height_map
			},
			u_displacement : {
				type: "f",
				value: 1.0,
			},
			u_param: {
				type: "f",
				value: 300.0,
			},
			u_instance_count: { 	
				type: "f",
				value: instances
			},
			u_vertex_displacement: {
				type: "f",
				value: new THREE.Vector3(0)
			},
			u_dimensions: {
				type: "f",
				value: new THREE.Vector2(w,d)
			},
			u_amplitude: {
				type: "f",
				value: 0.05
			},
			u_animate: {
				type: "f",
				value: false
			},
			u_time : {
				type: "f",
				value: 0.0
			},
			u_noise : {
				type: "f",
				value: 0.05
			},
			u_posy : {
				type: "f",
				value: 1.0
			},
			u_posx : {
				type: "f",
				value: 1.0
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
		grass_ref.current.material.uniforms.u_time.value = clock.getElapsedTime();
		// console.log(grass_particles.current.material.uniforms.u_time.value);
	});
 
	useEffect(() => {
		console.log(plane_uniforms);
		console.log(instances + " instances");
		console.log(height_map.source.data.width, height_map.source.data.height);
	});

	return (
		<>
			<group>
				<mesh
					ref={plane_ref}
					rotation={[(Math.PI / 2), 0, 0]}
				>
					<planeGeometry args={[w,d,w,d]}/>
					<shaderMaterial
						uniforms={plane_uniforms}
						vertexShader={planeVertexShader}
						fragmentShader={planeFragmentShader}
						side={THREE.DoubleSide}
					/>
				</mesh>
				<mesh ref={grass_ref}>
					<instancedBufferGeometry
						isInstancedBufferGeometry
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
						<bufferAttribute
							attach='attributes-normal'
							array={normals}
							count={normals.length / 3}
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
						uniforms={grassUniforms}
						vertexShader={
							simplex +
							grassVertexShader
						}
						fragmentShader={
							grassFragmentShader
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