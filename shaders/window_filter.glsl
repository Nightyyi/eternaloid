#version 330 

in vec2 fragTexCoord;

uniform sampler2D texture0;
uniform vec4 colDiffuse;

out vec4 color;

void main() {
    ivec2 texture_size = textureSize(texture0, 0);
    vec2 pixel = fragTexCoord * texture_size + 0.5;

    vec2 fl = floor(pixel);
    vec2 fr = fract(pixel);
    vec2 aa = fwidth(pixel) * 0.75;

    fr = smoothstep( vec2(0.5) - aa, vec2(0.5) + aa, fr);
    
    color = texture(texture0,((fl + fr - 0.5) / texture_size));
    // color = vec4(fragTexCoord,0.0,1.0)*colDiffuse;
}
