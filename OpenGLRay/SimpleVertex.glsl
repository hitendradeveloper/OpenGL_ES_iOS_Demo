attribute vec4 SourceColor;
attribute vec4 Position;

varying vec4 DestinationColor;

void main(void) {
    DestinationColor = SourceColor;
    gl_Position = Position;
}
