// ==========================================================================
// Vertex program for barebones GLFW boilerplate
//
// Author:  Sonny Chan, University of Calgary
// Date:    December 2015
// ==========================================================================
#version 410

//Transformations here
// location indices for these attributes correspond to those specified in the
// InitializeGeometry() function of the main program
layout(location = 0) in vec3 VertexPosition;
layout(location = 1) in vec2 VertexUV;
uniform float zoom;
uniform float xVal;
uniform float yVal;

// output to be interpolated between vertices and passed to the fragment stage
out vec2 uv;
out vec3 FragmentPosition;

void main()
{
    mat3x3 scalingMatrix = mat3x3(zoom, 0.0, 0.0, 
                                  0.0, zoom, 0.0, 
                                  0.0, 0.0, zoom);
    vec3 scaledPoint = scalingMatrix * VertexPosition;

    // assign vertex position without modification
    
    //gl_Position = vec4(scaledPoint.xy, 0.0, 1.0);

    mat4x4 translatingMatrix = mat4x4(1.0, 0.0, 0.0, xVal, 
                                        0.0, 1.0, 0.0, yVal, 
                                        0.0, 0.0, 1.0, 1.0, 
                                        0.0, 0.0, 0.0, 1.0);

    vec4 translatedPoint = vec4(scaledPoint.xy, 0.0, 1.0) * translatingMatrix;
    gl_Position = translatedPoint;


    // assign output colour to be interpolated
    uv = VertexUV;
    FragmentPosition = VertexPosition;
}
