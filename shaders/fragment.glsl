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
uniform int g_3;
uniform int g_5;
uniform int g_7;
uniform float G_array_1d_3 [3]={0.2,0.6,0.2};
uniform float G_array_1d_5 [5]={0.06,0.24,0.4,0.24,0.06};
uniform float G_array_1d_7 [7]={0.03,0.11,0.22,0.28,0.22,0.11,0.03};
float G_array_2d_3 [9];
float G_array_2d_5 [25];
float G_array_2d_7 [49];
void dimension_converter()
{int i,j;
	for(i=0;i<3;i++)
		{
			for(j=0;j<3;j++)
			{
				G_array_2d_3[i*3+j]=G_array_1d_3[i]*G_array_1d_3[j];
							}
        
		}
	for(i=0;i<5;i++)
		{
			for(j=0;j<5;j++)
			{
				G_array_2d_5[i*5+j]=G_array_1d_5[i]*G_array_1d_5[j];
			}
		}
	for(i=0;i<7;i++)
		{
			for(j=0;j<7;j++)
			{
				G_array_2d_7[i*7+j]=G_array_1d_7[i]*G_array_1d_7[j];
			}
		}

}
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
vec4[25] generate_kernel_5d(sampler2DRect imgTexture, vec2 xy)
{
    vec4 arr[25];
	arr[0] = texture(imgTexture, vec2(xy.x-2, xy.y+2)); //Top left
	arr[1] = texture(imgTexture, vec2(xy.x-1, xy.y+2)); //Top centre
	arr[2] = texture(imgTexture, vec2(xy.x, xy.y+2)); //Top right
	arr[3] = texture(imgTexture, vec2(xy.x+1, xy.y+2)); //Left
	arr[4] = texture(imgTexture, vec2(xy.x+2, xy.y+2)); //Centre
	arr[5] = texture(imgTexture, vec2(xy.x-2, xy.y+1)); 
    arr[6] = texture(imgTexture, vec2(xy.x-1, xy.y+1)); 
    arr[7] = texture(imgTexture, vec2(xy.x, xy.y+1)); 
    arr[8] = texture(imgTexture, vec2(xy.x+1, xy.y+1)); 
    arr[9] = texture(imgTexture, vec2(xy.x+2, xy.y+1)); 
    arr[10] = texture(imgTexture, vec2(xy.x-2, xy.y)); 
    arr[11] = texture(imgTexture, vec2(xy.x-1, xy.y)); 
    arr[12] = texture(imgTexture, vec2(xy.x, xy.y)); 
    arr[13] = texture(imgTexture, vec2(xy.x+1, xy.y)); 
    arr[14] = texture(imgTexture, vec2(xy.x+2, xy.y)); 
    arr[15] = texture(imgTexture, vec2(xy.x-2, xy.y-1)); 
    arr[16] = texture(imgTexture, vec2(xy.x-1, xy.y-1)); 
    arr[17] = texture(imgTexture, vec2(xy.x, xy.y-1)); 
    arr[18] = texture(imgTexture, vec2(xy.x+1, xy.y-1)); 
    arr[19] = texture(imgTexture, vec2(xy.x+2, xy.y-1)); 
    arr[20] = texture(imgTexture, vec2(xy.x-2, xy.y-2)); 
    arr[21] = texture(imgTexture, vec2(xy.x-1, xy.y-2)); 
    arr[22] = texture(imgTexture, vec2(xy.x, xy.y-2)); 
    arr[23] = texture(imgTexture, vec2(xy.x+1, xy.y-2)); 
    arr[24] = texture(imgTexture, vec2(xy.x+2, xy.y-2));
    return arr;
}
vec4[49] generate_kernel_7d(sampler2DRect imgTexture, vec2 xy)
{
    vec4 arr[49];
	arr[0] = texture(imgTexture, vec2(xy.x-3, xy.y+3)); //Top left
	arr[1] = texture(imgTexture, vec2(xy.x-2, xy.y+3)); //Top centre
	arr[2] = texture(imgTexture, vec2(xy.x-1, xy.y+3)); //Top right
	arr[3] = texture(imgTexture, vec2(xy.x,   xy.y+3)); //Left
	arr[4] = texture(imgTexture, vec2(xy.x+1, xy.y+3)); //Centre
	arr[5] = texture(imgTexture, vec2(xy.x+2, xy.y+3)); 
    arr[6] = texture(imgTexture, vec2(xy.x+3, xy.y+3)); 
    arr[7] = texture(imgTexture, vec2(xy.x-3, xy.y+2)); //Top left
	arr[8] = texture(imgTexture, vec2(xy.x-2, xy.y+2)); //Top centre
	arr[9] = texture(imgTexture, vec2(xy.x-1, xy.y+2)); //Top right
	arr[10]= texture(imgTexture, vec2(xy.x,   xy.y+2)); //Left
	arr[11]  = texture(imgTexture, vec2(xy.x+1, xy.y+2)); //Centre
	arr[12]  = texture(imgTexture, vec2(xy.x+2, xy.y+2)); 
    arr[13]  = texture(imgTexture, vec2(xy.x+3, xy.y+2)); 
    arr[14]  = texture(imgTexture, vec2(xy.x-3, xy.y+1)); //Top left
	arr[15]  = texture(imgTexture, vec2(xy.x-2, xy.y+1)); //Top centre
	arr[16]  = texture(imgTexture, vec2(xy.x-1, xy.y+1)); //Top right
	arr[17]  = texture(imgTexture, vec2(xy.x,   xy.y+1)); //Left
	arr[18]  = texture(imgTexture, vec2(xy.x+1, xy.y+1)); //Centre
	arr[19]  = texture(imgTexture, vec2(xy.x+2, xy.y+1)); 
    arr[20] = texture(imgTexture, vec2(xy.x+3, xy.y+1)); 
    arr[21] = texture(imgTexture, vec2(xy.x-3, xy.y)); //Top left
	arr[22] = texture(imgTexture, vec2(xy.x-2, xy.y)); //Top centre
	arr[23] = texture(imgTexture, vec2(xy.x-1, xy.y)); //Top right
	arr[24] = texture(imgTexture, vec2(xy.x,   xy.y)); //Left
	arr[25] = texture(imgTexture, vec2(xy.x+1, xy.y)); //Centre
	arr[26] = texture(imgTexture, vec2(xy.x+2, xy.y)); 
    arr[27] = texture(imgTexture, vec2(xy.x+3, xy.y)); 
    arr[28] = texture(imgTexture, vec2(xy.x-3, xy.y-1)); //Top left
	arr[29] = texture(imgTexture, vec2(xy.x-2, xy.y-1)); //Top centre
	arr[30]= texture(imgTexture, vec2(xy.x-1, xy.y-1)); //Top right
	arr[31] = texture(imgTexture, vec2(xy.x,   xy.y-1)); //Left
	arr[32] = texture(imgTexture, vec2(xy.x+1, xy.y-1)); //Centre
	arr[33] = texture(imgTexture, vec2(xy.x+2, xy.y-1)); 
    arr[34] = texture(imgTexture, vec2(xy.x+3, xy.y-1)); 
    arr[35] = texture(imgTexture, vec2(xy.x-3, xy.y-2)); //Top left
	arr[36] = texture(imgTexture, vec2(xy.x-2, xy.y-2)); //Top centre
	arr[37] = texture(imgTexture, vec2(xy.x-1, xy.y-2)); //Top right
	arr[38] = texture(imgTexture, vec2(xy.x,   xy.y-2)); //Left
	arr[39] = texture(imgTexture, vec2(xy.x+1, xy.y-2)); //Centre
	arr[40]= texture(imgTexture, vec2(xy.x+2, xy.y-2)); 
    arr[41] = texture(imgTexture, vec2(xy.x+3, xy.y-2)); 
    arr[42] = texture(imgTexture, vec2(xy.x-3, xy.y-3)); //Top left
	arr[43] = texture(imgTexture, vec2(xy.x-2, xy.y-3)); //Top centre
	arr[44] = texture(imgTexture, vec2(xy.x-1, xy.y-3)); //Top right
	arr[45] = texture(imgTexture, vec2(xy.x,   xy.y-3)); //Left
	arr[46] = texture(imgTexture, vec2(xy.x+1, xy.y-3)); //Centre
	arr[47] = texture(imgTexture, vec2(xy.x+2, xy.y-3)); 
    arr[48] = texture(imgTexture, vec2(xy.x+3, xy.y-3)); 
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
void filterToKernel(vec4[25] kernel, float[25] filter)
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
void filterToKernel(vec4[49] kernel, float[49] filter)
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
    dimension_converter();
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
    if(g_3==1)
        {
            vec4[9] kernel = generate_kernel(imageTexture, uv);
            filterToKernel(kernel, G_array_2d_3);
            filterColor = abs(filterColor/2);
            }
    if(g_5==1)
        {
            vec4[25] kernel = generate_kernel_5d(imageTexture, uv);
            filterToKernel(kernel, G_array_2d_5);
            filterColor = abs(filterColor/2);
            }
    if(g_7==1)
        {
            vec4[49] kernel = generate_kernel_7d(imageTexture, uv);
            filterToKernel(kernel, G_array_2d_7);
            filterColor = abs(filterColor/2);
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
