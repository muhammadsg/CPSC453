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

uniform float gsR;
uniform float gsG;
uniform float gsB;

// first output is mapped to the framebuffer's colour index by default
out vec4 FragmentColour;

uniform sampler2DRect imageTexture;
vec4 color;
vec4 saturation;


//glEnable(GL_FRAMEBUFFER_SRGB); 


void main(void)
{

    color = texture(imageTexture, uv);
    vec4 GreyScaleColor = vec4(color.r*=gsR, color.g*=gsG, color.b*=gsB, color.a);
    
    // write colour output without modification
    //FragmentColour = texture(imageTexture, uv);
    
	FragmentColour = GreyScaleColor;

}
