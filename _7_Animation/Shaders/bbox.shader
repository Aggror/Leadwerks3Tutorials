SHADER version 1
@OpenGL2.Vertex
//Uniforms
uniform mat4 camerainversematrix;
uniform mat4 projectioncameramatrix;
uniform mat4 entitymatrix;
uniform vec4 materialcolor;
uniform mat4 cameramatrix;

//Attributes
attribute vec3 vertex_position;
attribute vec3 vertex_normal;
attribute vec4 vertex_color;
attribute vec2 vertex_texcoords0;
attribute vec3 vertex_binormal;
attribute vec3 vertex_tangent;

//Outputs
varying vec4 ex_color;

void main(void)
{
	mat4 entitymatrix_=entitymatrix;
	entitymatrix_[0][3]=0.0;
	entitymatrix_[1][3]=0.0;
	entitymatrix_[2][3]=0.0;
	entitymatrix_[3][3]=1.0;
		
	gl_Position = projectioncameramatrix * entitymatrix_ * vec4(vertex_position, 1.0);
	
	ex_color = vec4(entitymatrix[0][3],entitymatrix[1][3],entitymatrix[2][3],entitymatrix[3][3]);
}






@OpenGL2.Fragment
uniform vec4 materialcolor;

varying vec4 ex_color;

void main(void)
{
	gl_FragColor = ex_color * materialcolor;
}



@OpenGLES2.Vertex
//Uniforms
uniform mat4 camerainversematrix;
uniform mat4 projectioncameramatrix;
uniform mat4 entitymatrix;
uniform vec4 materialcolor;
uniform mat4 cameramatrix;

//Attributes
attribute vec3 vertex_position;
attribute vec3 vertex_normal;
attribute vec4 vertex_color;
attribute vec2 vertex_texcoords0;
attribute vec3 vertex_binormal;
attribute vec3 vertex_tangent;

//Outputs
varying vec4 ex_color;

void main(void)
{
	mat4 entitymatrix_=entitymatrix;
	entitymatrix_[0][3]=0.0;
	entitymatrix_[1][3]=0.0;
	entitymatrix_[2][3]=0.0;
	entitymatrix_[3][3]=1.0;
		
	gl_Position = projectioncameramatrix * entitymatrix_ * vec4(vertex_position, 1.0);
	
	ex_color = vec4(entitymatrix[0][3],entitymatrix[1][3],entitymatrix[2][3],entitymatrix[3][3]);
}



@OpenGLES2.Fragment
uniform mediump vec4 materialcolor;

varying mediump vec4 ex_color;

void main(void)
{
	gl_FragColor = ex_color * materialcolor;
}



