import { use, useEffect, useState } from "react";

import {Canvas, useFrame, useThree} from "@react-three/fiber";
import styles from "../styles/Home.module.css";

import OrbitControls from "../components/orbit_controls";

import Star from "../components/star";

// import Model from "../components/Scene";
import Model from "../components/Glasses";

import Text from "../components/text";

export default function Home() {
	// var light = new THREE.DirectionalLight()
	return (
		<div className={styles.scene}>
			<Canvas
				shadows
				className={styles.canvas}
				camera={{
					position: [0, 0, 1000]
					// position: [0, 0, 100]
				}}
			>
				<OrbitControls
					autoRotate={false}
					enableDamping={true}
					enableZoom={true}
					enablePan={true}
					dampingFactor={0.5}
					maxDistance={1000}
					minDistance={100}
				/>
				<Star stars={2000}/>
				<hemisphereLight
					skyColor={0xffffff}
					groundColor={0x444444}
					intensity={1.5}
					position={[-50,200,100]}
				/>
				{/* <ambientLight 
					castShadow={true}
					intensity={5}
					position={[0,0,0]}
				/> */}
				{/* <lightProbe 
					intensity={10}
					position={[0,0,20]}
				/> */}
				{/* <spotLight
					intensity={1}
					angle={Math.PI/1}
					// penumbra={1}
					// decay={50}
					// color={0xE40046}
					// map={texture}
				/> */}
				<directionalLight 
					color={0xffffff}
					intensity={1}
					position={[-50,200,200]}
				/>
				<Text 
					position={[0,45,0]} 
					text={"You can do this!"}
				/>
				<Model position={[0,-25,0]} scale={0.35}/>
				<Text 
					position={[0,-40,0]} 
					text={"I believe in YOU"}
				/>
			</Canvas>
		</div>	
	)
}
