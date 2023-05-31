import * as THREE from "three";

import { useEffect, useRef, memo } from "react";

import { useHelper, GizmoHelper, GizmoViewport, AccumulativeShadows, RandomizedLight } from "@react-three/drei";
import { useControls } from "leva";

function LightExample() {
	const hemisphere_light = useRef();
	const directional_light = useRef();

	useHelper(hemisphere_light, THREE.HemisphereLightHelper, 1, "blue");
	useHelper(directional_light, THREE.DirectionalLightHelper, 1, "red");

	const ambient_light_params = useControls('ambient light', {
		intensity: {value: 0.0, min: 0, max: 10, step: 0.01 },
		color: "#ffffff",
	});

	// const hemisphere_light_params = useControls('hemisphere light', {
	// 	position: [0, 5, 0],
	// 	intensity: { value: 0.5, min: 0, max: 100, step: 0.05 },
	// 	skyColor: '#ffffff',
	// });

	const directional_light_params = useControls('directional light', {
		castShadow: true,
		position: [0, 10, 100],
		intensity: { value: 1, min: 0, max: 10, step: 0.05 },
		color: '#ffffff'
	});

	return (
		<>
			<ambientLight
				{...ambient_light_params}
			/>
			{/* <hemisphereLight
				ref={hemisphere_light}
				{...hemisphere_light_params}
			/> */}
			<directionalLight
				ref={directional_light}
				{...directional_light_params}
			/>
		</>
	)
}


export { LightExample }