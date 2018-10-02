/*
 * Scene.cpp
 *
 *  Created on: Sep 10, 2018
 *  Author: John Hall
 */

#include "Scene.h"

#include <iostream>

#include "RenderingEngine.h"

#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <glm/gtc/type_ptr.hpp>

//**Must include glad and GLFW in this order or it breaks**
#include <glad/glad.h>
#include <GLFW/glfw3.h>

#include "texture.h"
MyTexture texture1,texture2,texture3,texture4,texture5,texture6,texture7;
Scene::Scene(RenderingEngine* renderer) : renderer(renderer) {

	
	InitializeTexture(&texture1, "image1-mandrill.png", GL_TEXTURE_RECTANGLE);
	InitializeTexture(&texture2, "image2-uclogo.png", GL_TEXTURE_RECTANGLE);
	InitializeTexture(&texture3, "image3-aerial.jpg", GL_TEXTURE_RECTANGLE);
	InitializeTexture(&texture4, "image4-thirsk.png", GL_TEXTURE_RECTANGLE);
	InitializeTexture(&texture5, "image5-pattern.png", GL_TEXTURE_RECTANGLE);
	InitializeTexture(&texture6, "image6-bubble.png", GL_TEXTURE_RECTANGLE);
	InitializeTexture(&texture7, "image1-mandrill.png", GL_TEXTURE_RECTANGLE);
	//Load texture uniform
	//Shaders need to be active to load uniforms
	glUseProgram(renderer->shaderProgram);
	//Set which texture unit the texture is bound to
	glActiveTexture(GL_TEXTURE0);
	//Bind the texture to GL_TEXTURE0
	glBindTexture(GL_TEXTURE_RECTANGLE, texture1.textureID);
	//Get identifier for uniform
	GLuint uniformLocation = glGetUniformLocation(renderer->shaderProgram, "imageTexture");
	//Load texture unit number into uniform
	glUniform1i(uniformLocation, 0);

	if(renderer->CheckGLErrors()) {
		std::cout << "Texture creation failed" << std::endl;
	}

		// three vertex positions and assocated colours of a triangle
	rectangle.verts.push_back(glm::vec3( -0.9f, -0.9f, 1.0f));
	rectangle.verts.push_back(glm::vec3( 0.9f,  -0.9f, 1.0f));
	rectangle.verts.push_back(glm::vec3( 0.9f, 0.9f, 1.0f));
	rectangle.verts.push_back(glm::vec3( -0.9f, -0.9f, 1.0f));
	rectangle.verts.push_back(glm::vec3( 0.9f, 0.9f, 1.0f));
	rectangle.verts.push_back(glm::vec3( -0.9f, 0.9f, 1.0f));

	/*rectangle.colors.push_back(glm::vec3( 1.0f, 0.0f, 0.0f));
	rectangle.colors.push_back(glm::vec3( 1.0f, 0.0f, 0.0f));
	rectangle.colors.push_back(glm::vec3( 1.0f, 0.0f, 0.0f));
	rectangle.colors.push_back(glm::vec3( 1.0f, 0.0f, 0.0f));
	rectangle.colors.push_back(glm::vec3( 1.0f, 0.0f, 0.0f));
	rectangle.colors.push_back(glm::vec3( 1.0f, 0.0f, 0.0f));*/



	rectangle.drawMode = GL_TRIANGLES;

	rectangle.uvs.push_back(glm::vec2( 0.0f, 0.0f));
	rectangle.uvs.push_back(glm::vec2( float(texture.width), 0.f));
	rectangle.uvs.push_back(glm::vec2( float(texture.width), float(texture.height)));
	rectangle.uvs.push_back(glm::vec2( 0.0f, 0.0f));
	rectangle.uvs.push_back(glm::vec2( float(texture.width), float(texture.height)));
	rectangle.uvs.push_back(glm::vec2(0.0f, float(texture.height)));

	//Construct vao and vbos for the triangle
	RenderingEngine::assignBuffers(rectangle);

	//Send the triangle data to the GPU
	//Must be done every time the triangle is modified in any way, ex. verts, colors, normals, uvs, etc.
	RenderingEngine::setBufferData(rectangle);

	//Add the triangle to the scene objects
	objects.push_back(rectangle);

}
void Scene::Reload(int sc)
{
	if(sc==1)
		glBindTexture(GL_TEXTURE_RECTANGLE, texture1.textureID);
	if(sc==2)
		glBindTexture(GL_TEXTURE_RECTANGLE, texture2.textureID);
	if(sc==3)
		glBindTexture(GL_TEXTURE_RECTANGLE, texture3.textureID);
	if(sc==4)
		glBindTexture(GL_TEXTURE_RECTANGLE, texture4.textureID);
	if(sc==5)
		glBindTexture(GL_TEXTURE_RECTANGLE, texture5.textureID);
	if(sc==6)
		glBindTexture(GL_TEXTURE_RECTANGLE, texture6.textureID);
	if(sc==7)
		glBindTexture(GL_TEXTURE_RECTANGLE, texture7.textureID);	
}
Scene::~Scene() {

}

void Scene::displayScene() {
	renderer->RenderScene(objects);
}

