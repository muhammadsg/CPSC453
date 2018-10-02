// ==========================================================================
// Vertex program for barebones GLFW boilerplate
//
// Author:  Sonny Chan, University of Calgary
// Date:    December 2015
// ==========================================================================
#version 410

// interpolated colour received from vertex stage
in vec2 uv;
in vec3 FragmentPosition;

// first output is mapped to the framebuffer's colour index by default
out vec4 FragmentColour;

uniform sampler2DRect imageTexture;
uniform float time;

vec2 waveOffset(vec2 position){
    float distFromCenter = length(position);
    float frequency = 12.0;
    return vec2(cos(distFromCenter*frequency + time), sin(distFromCenter*frequency + time))* 10.0;
}

void main(void)
{
    // write colour output without modification
    //FragmentColour = vec4(Colour, 0);
	FragmentColour = texture(imageTexture, uv+waveOffset(FragmentPosition.xy));

}
