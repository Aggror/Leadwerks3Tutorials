SHADER version 1
@OpenGL2.Vertex
//Uniforms
uniform mat4 entitymatrix;
uniform mat4 projectioncameramatrix;

//Attributes
attribute vec3 vertex_position;
attribute vec4 vertex_color;
attribute vec2 vertex_texcoords0;
attribute vec2 vertex_texcoords1;
attribute vec3 vertex_normal;

varying vec4 color;
varying vec2 texcoords0;
varying vec2 texcoords1;
varying float blendfunction;

void main ()
{	
	gl_Position = projectioncameramatrix * vec4(vertex_position, 1.0);
	color.r = 1.0 - vertex_color.r;
	color.g = 1.0 - vertex_color.g;
	color.b = 1.0 - vertex_color.b;
	color.a = vertex_color.a;
	texcoords0 = vertex_texcoords0;
	texcoords1 = vertex_texcoords1;
	blendfunction = vertex_normal.x;
}
@OpenGL2.Fragment
uniform sampler2D texture0;
uniform float currenttime;

varying vec4 color;
varying vec2 texcoords0;
varying vec2 texcoords1;
varying float blendfunction;

void main()
{
	vec4 color0 = texture2D(texture0,texcoords0);
	vec4 color1 = texture2D(texture0,texcoords1);
	//float blend = (currenttime/500.0 - (float)(int)currenttime/500.0);
	float blend = blendfunction; // mod(currentlife,333.3)/(333.3);		
	//a - (n* floor(a/n))
	//outcolor = outcolor * texture2D(texture0,texcoords1);
	gl_FragColor = color * (color0 * (1.0-blend) + color1 * blend);
	//gl_FragColor = vec4(0.0,1.0,1.0,1.0);
}
@OpenGLES2.Vertex
//Uniforms
uniform mat4 entitymatrix;
uniform mat4 projectioncameramatrix;

//Attributes
attribute vec3 vertex_position;
attribute vec4 vertex_color;
attribute vec2 vertex_texcoords0;
attribute vec2 vertex_texcoords1;
attribute vec3 vertex_normal;

varying vec4 color;
varying vec2 texcoords0;
varying vec2 texcoords1;
varying float blendfunction;

void main ()
{	
	gl_Position = projectioncameramatrix * vec4(vertex_position, 1.0);
	color.r = 1.0 - vertex_color.r;
	color.g = 1.0 - vertex_color.g;
	color.b = 1.0 - vertex_color.b;
	color.a = vertex_color.a;
	texcoords0 = vertex_texcoords0;
	texcoords1 = vertex_texcoords1;
	blendfunction = vertex_normal.x;
}
@OpenGLES2.Fragment
precision highp float; 

uniform sampler2D texture0;
uniform float currenttime;

varying vec4 color;
varying vec2 texcoords0;
varying vec2 texcoords1;
varying float blendfunction;

void main()
{
	vec4 color0 = texture2D(texture0,texcoords1);
	vec4 color1 = texture2D(texture0,texcoords1);
	//float blend = (currenttime/500.0 - (float)(int)currenttime/500.0);
	float blend = blendfunction; // mod(currentlife,333.3)/(333.3);		
	//a - (n* floor(a/n))
	//outcolor = outcolor * texture2D(texture0,texcoords1);
	gl_FragColor = color * (color0 * (1.0-blend) + color1 * blend);
	//gl_FragColor = vec4(0.0,1.0,1.0,1.0);
}
