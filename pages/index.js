import { use, useEffect, useState } from "react";

import {Canvas, useFrame, useThree} from "@react-three/fiber";

import Link from 'next/link'

import styles from "@/styles/Home.module.css";

export default function Home() {
	return (
		<div>
			<Link href="/grass">
				<h1>Grass</h1>
			</Link>
		</div>
	)
}
