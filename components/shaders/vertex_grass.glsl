// uniform mat4 projectionMatrix;
// uniform mat4 viewMatrix;
// uniform mat4 modelViewMatrix;
// uniform mat4 modelMatrix;

// attribute vec3 position;

attribute vec3 terrPosi;

void main() {
    // vec3 finalPosition = position + vec3(-1.6778351068496704, 0, -1.7341969013214111);
    vec3 finalPosition = position + terrPosi;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(finalPosition, 1.0);
}