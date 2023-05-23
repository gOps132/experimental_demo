import * as THREE from "three";

// import { extend } from "@react-three/fiber";
import { FontLoader } from 'three/examples/jsm/loaders/FontLoader';
// import { TextGeometry } from 'three/examples/jsm/geometries/TextGeometry';
import { useFrame, useThree } from "@react-three/fiber";

// import cedarville from "@/public/font/Cedarville_Cursive_Regular.json";
import pacifico from "@/public/font/Pacifico_Regular.json";

import { useEffect, useRef } from "react";

import { Center, Text3D } from "@react-three/drei";

export default function CustomText(props){
	const mat_ref = useRef();
	const font = new FontLoader().parse(pacifico);
	const { camera } = useThree();
	useFrame(() => {
		mat_ref.current.rotation.copy(camera.rotation);
	})
	return (
		<Center middle top
			position={props.position}
		>
			<Text3D
				ref={mat_ref}
				font={pacifico}
				scale={5}
				height={0.1}
				color={props.color ? props.color : "white"}
				curveSegments={10}
				bevelEnabled={true}
				bevelThickness={0}
				bevelSize={0}
				bevelOffset={0}
				bevelSegments={0}
			>
				{props.text}
			</Text3D>
		</Center>
	); 
} 