// ==========================================================================
// Vertex program for barebones GLFW boilerplate
//
// Author:  Sonny Chan, University of Calgary
// Date:    December 2015
// ==========================================================================
#version 410
//Image effects here (thsis is run per pixel)
// interpolated colour received from vertex stage
in vec2 uv;
in vec3 FragmentPosition;

// first output is mapped to the framebuffer's colour index by default
out vec4 FragmentColour;

uniform sampler2DRect imageTexture;

void main(void)
{
    // write colour output without modification
    //FragmentColour = vec4(Colour, 0);
	FragmentColour = texture(imageTexture, uv);

}
