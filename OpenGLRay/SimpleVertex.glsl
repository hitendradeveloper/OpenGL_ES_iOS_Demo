attribute vec4 SourceColor;
attribute vec4 Position;

varying vec4 DestinationColor;
uniform mat4 Projection;
uniform mat4 Modelview;

attribute vec2 TexCoordIn;
varying vec2 TexCoordOut;

void main(void) {
    DestinationColor = SourceColor;
    gl_Position = Projection * Modelview * Position;
    TexCoordOut = TexCoordIn;
}
