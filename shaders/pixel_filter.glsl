#version 330 

in vec2 fragTexCoord;

uniform sampler2D texture0;

out vec4 color;

void main() {
    ivec2 texture_size = textureSize(texture0, 0);
    vec2 pixel = fragTexCoord * texture_size;

    vec2 seam = floor(pixel + 0.5);
    vec2 dudv = fwidth(pixel);
    vec2 pixel_n = seam + clamp( (pixel - seam) / dudv, -0.5, 0.5);
    
    // color = vec4(texture(texture0,fragTexCoord).xyz, (pixel / texture_size).x);
    color = texture(texture0,pixel_n / texture_size);
}
