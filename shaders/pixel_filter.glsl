#version 330 

in vec2 fragTexCoord;

uniform sampler2D texture0;

out vec4 color;

void main() {
    ivec2 texture_size = textureSize(texture0, 0);
    vec2 pixel = fragTexCoord * texture_size + 0.5;

    vec2 fl = floor(pixel);
    vec2 fr = fract(pixel);
    vec2 aa = fwidth(pixel) * 0.75;

    fr = smoothstep( vec2(0.5) - aa, vec2(0.5) + aa, fr);
    
    // color = vec4(texture(texture0,fragTexCoord).xyz, (pixel / texture_size).x);
    vec2 step_x = vec2(texture_size.x,0.0);
    vec2 step_y = vec2(0.0,texture_size.y);
    vec4 color_plus = vec4(0.0,0.0,0.0,1.0);
    vec2 meow = (fl + fr - 0.5);
    for (int i = 0; i < 3; i++)
    {
      color_plus += texture(texture0,((meow-step_x)))/6;
      color_plus += texture(texture0,((meow-step_y)))/6;
      step_x += vec2(texture_size.x,0.0);
      step_y += vec2(0.0,texture_size.y);
      
    }
    color = color_plus;
    // color = vec4(((fl + fr - 0.5) / texture_size),0.0,1.0);
    // color = vec4(fragTexCoord,0.0,1.0);
}
