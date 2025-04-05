#version 100

precision mediump float;

// Input vertex attributes (from vertex shader)
varying vec2 fragTexCoord;
varying vec4 fragColor;

// Input uniform values
uniform sampler2D texture0;
uniform vec4 colDiffuse;

// NOTE: Add your custom variables here

const vec2 size = vec2(900, 450);   // render size
const float samples = 9.0;          // pixels per axis; higher = bigger glow, worse performance
const float quality = 1.0;             // lower = smaller glow, better quality

void main()
{
    vec4 sum = vec4(0);
    vec2 sizeFactor = vec2(1)/size*quality;

    // Texel color fetching from texture sampler
    vec4 source = texture2D(texture0, fragTexCoord);

    const int range = 2;            // should be = (samples - 1)/2;

    for (int x = -range; x <= range; x++)
    {
        for (int y = -range; y <= range; y++)
        {
            // vec4 value = texture2D(texture0, fragTexCoord + vec2(x, y)*sizeFactor);
            // float bloomable = float(value.x + value.y + value.z)/3 > 240);
            // sum += value * bloomable;
            vec4 valval = texture2D(texture0, fragTexCoord + vec2(x, y)*sizeFactor);
            float bloomable = float((valval.x + valval.y + valval.z) > 1.9) * 1.5;
            sum += valval*bloomable;
        }
    }

    // Calculate final fragment color
    gl_FragColor = ((sum/(samples*samples)) + source)*colDiffuse;
}
