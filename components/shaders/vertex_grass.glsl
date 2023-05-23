// uniform mat4 projectionMatrix;
// uniform mat4 viewMatrix;
// uniform mat4 modelViewMatrix;
// uniform mat4 modelMatrix;

// attribute vec3 position;

attribute vec3 terrPosi;

void main() {
    vec3 finalPosition = position;
    finalPosition.x *= 0.1;
    finalPosition.y += 0.5;

    finalPosition += terrPosi;

    gl_PointSize = 100.0;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(finalPosition, 1.0);
}