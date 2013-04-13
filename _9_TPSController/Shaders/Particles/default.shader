SHADER version 1
@OpenGL2.Vertex
//Uniforms
uniform mat4 entitymatrix;
uniform mat4 projectioncameramatrix;

//Attributes
attribute vec3 vertex_position;
attribute vec4 vertex_color;
attribute vec2 vertex_texcoords0;

varying vec4 ex_color;
varying vec2 texcoords0;

void main ()
{	
	gl_Position = projectioncameramatrix * vec4(vertex_position, 1.0);
	ex_color.r = 1.0 - vertex_color.r;
	ex_color.g = 1.0 - vertex_color.g;
	ex_color.b = 1.0 - vertex_color.b;
	ex_color.a = vertex_color.a;
	texcoords0 = vertex_texcoords0;
}
@OpenGL2.Fragment
uniform sampler2D texture0;
varying vec4 ex_color;
varying vec2 texcoords0;

void main()
{
	gl_FragColor = ex_color * texture2D(texture0,texcoords0);
}
@OpenGLES2.Vertex
//Uniforms
uniform mat4 entitymatrix;
uniform mat4 projectioncameramatrix;

//Attributes
attribute vec3 vertex_position;
attribute vec4 vertex_color;
attribute vec2 vertex_texcoords0;

varying vec4 color;
varying vec2 texcoords0;

void main ()
{	
	gl_Position = projectioncameramatrix * vec4(vertex_position, 1.0);
	color.r = 1.0 - vertex_color.r;
	color.g = 1.0 - vertex_color.g;
	color.b = 1.0 - vertex_color.b;
	color.a = vertex_color.a;
	texcoords0 = vertex_texcoords0;
}
@OpenGLES2.Fragment
precision highp float; 

uniform sampler2D texture0;
varying vec4 color;
varying vec2 texcoords0;

void main()
{
	gl_FragColor = color * texture2D(texture0,texcoords0);
	//gl_FragColor = vec4(1.0,1.0,1.0,1.0);
	//gl_FragColor.a=0.0;
}
