import React from "react";
import * as THREE from "three";

import { useFrame, useThree } from "@react-three/fiber";

import {EaseInOutQuad, EaseOutCirc} from "./animation_helper";

function Star(props) {
    let star_ref = React.useRef();
    const star_count = (props) ? props.stars : 5000;
    const vertices = [];
    for(let i=0; i < star_count; i++) {
        const x = (Math.random() - 0.5) * 2000;
        const y = (Math.random() - 0.5) * 2000;
        const z = (i > (star_count/2) ? -(Math.random()) * 3000 : (Math.random()) * 3000);
        vertices.push(x,y,z);
    }
    const star_vertices = new Float32Array(vertices);

    // TODO: not sure where to put this, so ill just hack this in here
    // see video: https://www.youtube.com/watch?v=L1WJYmczPO0
	const { camera } = useThree();
    let x = 0;
    let stop_zoomin = false;
    useFrame(({clock}) => {
        // z position 1000 to 100
        let b = camera.position.z;
        if (b > 100 && !stop_zoomin) {
            // camera.position.z = b - (b * (x * x * x));
            camera.position.z = b - (-b * (-x*x*x));
        } else
            stop_zoomin = true;
        if (x < 1) {
            x += 0.01;
            // console.log(Math.round(x * 100) / 100);
        }
        star_ref.current.rotation.y = clock.getElapsedTime() * 0.1;
	})

    return (
        <points ref={star_ref}>
            <bufferGeometry attach="geometry">
                <bufferAttribute
                    attach="attributes-position"
                    count={star_vertices.length / 3}
                    array={star_vertices}
                    itemSize={3}
                    usage={THREE.DynamicDrawUsage}
                />
                <pointsMaterial attach="material" color={0xFFFFFF} vertexColors size={10} sizeAttenuation={false} />
            </bufferGeometry>
        </points>
    )
}

export default Star;