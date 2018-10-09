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
uniform int vign;
uniform int neg;
uniform int sobelV;
uniform int sobelH;
uniform int sobelU;

// first output is mapped to the framebuffer's colour index by default
out vec4 FragmentColour;

uniform sampler2DRect imageTexture;
vec4 color;
vec4 saturation;
vec4 filterColor;

float colorWork;
//rad of vignette
float rad = 0.60;
//softness of vignette
float soft = 0.35;
vec2 resolution = vec2(512,512);



vec4[9] generate_kernel(sampler2DRect imgTexture, vec2 xy)
{
    vec4 arr[9];

	arr[0] = texture(imgTexture, vec2(xy.x--, xy.y++)); //Top left
	arr[1] = texture(imgTexture, vec2(xy.x, xy.y++)); //Top centre
	arr[2] = texture(imgTexture, vec2(xy.x++, xy.y++)); //Top right
	arr[3] = texture(imgTexture, vec2(xy.x--, xy.y)); //Left
	arr[4] = texture(imgTexture, vec2(xy.x, xy.y)); //Centre
	arr[5] = texture(imgTexture, vec2(xy.x++, xy.y)); //Right
    arr[6] = texture(imgTexture, vec2(xy.x--, xy.y--)); //Bottom left
	arr[7] = texture(imgTexture, vec2(xy.x, xy.y--)); //Bottom centre
	arr[8] = texture(imgTexture, vec2(xy.x++, xy.y--)); //Bottom right

    return arr;
}

void filterToKernel(vec4[9] kernel, float[9] filter)
{
    for(int i = 0; i < filter.length; i++)
    {
        filterColor += kernel[i] * filter[i]; //Not sure if this is correctly doin sobel
    }

    //vec4 sobel_edge_v = kernel[2] + (2.0*kernel[5]) + kernel[8] - (kernel[0] + (2.0*kernel[3]) + kernel[6]);
  	//filterColor = abs(sobel_edge_v);
    //vec4 sobel_edge_h = kernel[0] + (2.0*kernel[1]) + kernel[2] - (kernel[6] + (2.0*kernel[7]) + kernel[8]);
	//filterColor = sqrt((sobel_edge_h * sobel_edge_h) + (sobel_edge_v * sobel_edge_v));
} 

void main(void)
{
    color = texture(imageTexture, uv);

    if(vign == 1)
    {
	    // Finding the center of window
	    vec2 position = (gl_FragCoord.xy / resolution.xy) - vec2(0.5);
	
	    //Finding length from the center
	    float len = length(position);
	
	    //Defining our effect, uses smoothstep function to 
	    float vignette = smoothstep(rad, rad-soft, len);
	
	    //Applying vignette
	    color.rgb *= vignette;
	    filterColor = color;
    }

    filterColor = vec4(color.r*gsR, color.g*gsG, color.b*gsB, color.a);

    if(gsR != 1)
    {
        colorWork = (color.r*gsR + color.g*gsG + color.b*gsB);
        filterColor = vec4(colorWork, colorWork, colorWork, 0.0);
    }

    if(sobelV != 0 || sobelH != 0 || sobelU != 0)
    {
        vec4[9] kernel = generate_kernel(imageTexture, uv);

        if(sobelV == 1)
        { 
                float[9] vertS = float[](-1.0f, 0.0f, 1.0f,
                                         -2.0f, 0.0f, 2.0f,
                                         -1.0f, 0.0f, 1.0f); 
                filterToKernel(kernel, vertS);
                filterColor = abs(filterColor);
        }

        if(sobelH == 1)
        { 
                float[9] vertS = float[](-1.0f, -2.0f, -1.0f,
                                          0.0f, 0.0f, 0.0f,
                                          1.0f, 2.0f, 1.0f); 
                filterToKernel(kernel, vertS);
                filterColor = 1 - abs(filterColor);
        }

        if(sobelU == 1)
        { 
                float[9] vertS = float[](0.0f, -1.0f, 0.0f,
                                        -1.0f, 5.0f, -1.0f,
                                         0.0f, -1.0f, 0.0f); 
                filterToKernel(kernel, vertS);
                filterColor =  1 - abs(filterColor);
        }
    }
    
   
    if (neg == 1)
    {
	    FragmentColour = (1 - filterColor);
    }
    else
    {
        FragmentColour = filterColor;
    }
}
