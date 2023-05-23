import { use, useEffect, useState } from "react";

import {Canvas, useFrame, useThree} from "@react-three/fiber";
import styles from "../styles/Home.module.css";

import OrbitControls from "../components/orbit_controls";

import Text from "../components/text";

export default function Home() {
	return (
		<div className={styles.scene}>
			<Canvas
				shadows
				className={styles.canvas}
				camera={{
					position: [0, 0, 100]
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
			</Canvas>
		</div>	
	)
}
