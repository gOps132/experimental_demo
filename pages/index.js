import { use, useEffect, useState } from "react";

import {Canvas, extend, useFrame, useThree} from "@react-three/fiber";
import styles from "@/styles/Home.module.css";

import OrbitControls from "@/components/orbit_controls";

import { useHelper, GizmoHelper, GizmoViewport, AccumulativeShadows, RandomizedLight } from "@react-three/drei";

import { GrassField } from "@/components/grass";
import { LightExample } from "@/components/lights";

export default function Home() {	
	return (
		<div className={styles.scene}>
			<Canvas
				shadows
				className={styles.canvas}
				camera={{
					// position: [0, 3, 5]
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
				<axesHelper/>
				
				<GrassField
					instances={10000}
					width={20}
					dimension={20}
					height={0}
				/>

				<LightExample/>

				{/* add drei grid here as well */}

				<GizmoHelper alignment="bottom-right" margin={[80, 80]}>
				<GizmoViewport axisColors={['#9d4b4b', '#2f7f4f', '#3b5b9d']} labelColor="white" />
			</GizmoHelper>
			</Canvas>
		</div>	
	)
}
