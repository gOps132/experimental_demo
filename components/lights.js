import * as THREE from "three";

import { useEffect, useRef, memo } from "react";

import Model from "./models/Glasses";
import { useHelper, GizmoHelper, GizmoViewport, AccumulativeShadows, RandomizedLight } from "@react-three/drei";
import { useControls } from "leva";

function LightExample() {
	const hemisphere_light = useRef();
	const directional_light = useRef();

	useHelper(hemisphere_light, THREE.HemisphereLightHelper, 1, "blue");
	useHelper(directional_light, THREE.DirectionalLightHelper, 1, "red");

	const hemisphere_light_params = useControls('hemisphere light', {
		position: [0, 5, 0],
		intensity: { value: 0.5, min: 0, max: 100, step: 0.05 },
		skyColor: '#ffffff',
		groundColor: '#444444',
	});

	const directional_light_params = useControls('directional light', {
		castShadow: true,
		position: [0, 10, 100],
		intensity: { value: 1, min: 0, max: 100, step: 0.05 },
		color: '#ffffff'
	});

	// const plane_params = useControls('plane', {
	// 	recieveShadow: true,
	// 	color: '#6f6f6f',
	// })

	return (
		<>
			<hemisphereLight
				ref={hemisphere_light}
				{...hemisphere_light_params}
			/>
			<directionalLight
				ref={directional_light}
				{...directional_light_params}
			/>
			<Model scale={0.05} />
			{/* <mesh
				rotation={[(Math.PI / 2), 0, 0]}
			>
				<planeGeometry
					args={[20,20]}
				/>
				<meshBasicMaterial
					{...plane_params}
					side={THREE.DoubleSide}
				/>
			</mesh> */}
		</>
	)
}


export { LightExample }