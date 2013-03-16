SHADER version 1
@OpenGL2.Vertex
#version 120

//Uniforms
uniform mat4 camerainversematrix;
uniform mat4 projectioncameramatrix;
uniform mat4 entitymatrix;
uniform vec4 materialcolor;

//Inputs
attribute vec3 vertex_position;
attribute vec2 vertex_texcoords0;
//attribute vec3 vertex_normal;
//attribute vec4 vertex_color;
//attribute vec3 vertex_binormal;
//attribute vec3 vertex_tangent;

//Outputs
varying vec4 ex_color;
varying vec2 ex_texcoords0;
varying vec3 ex_normal;
varying vec3 ex_tangent;
varying vec3 ex_binormal;
varying vec3 ex_vertexposition;

void main(void)
{
	mat4 entitymatrix_=entitymatrix;
	entitymatrix_[0][3]=0.0;
	entitymatrix_[1][3]=0.0;
	entitymatrix_[2][3]=0.0;
	entitymatrix_[3][3]=1.0;
	
	gl_Position = projectioncameramatrix * entitymatrix_ * vec4(vertex_position, 1.0);
	
	mat3 nmat = mat3(camerainversematrix[0].xyz,camerainversematrix[1].xyz,camerainversematrix[2].xyz);
	nmat = nmat * mat3(entitymatrix[0].xyz,entitymatrix[1].xyz,entitymatrix[2].xyz);
	
	//ex_normal = normalize(nmat * vertex_normal);
	//ex_tangent = normalize(nmat * vertex_tangent);
	//ex_binormal = normalize(nmat * vertex_binormal);
	
	ex_color = vec4(entitymatrix[0][3],entitymatrix[1][3],entitymatrix[2][3],entitymatrix[3][3]) * materialcolor;
	ex_texcoords0 = vertex_texcoords0;
	
	ex_vertexposition = vec3(entitymatrix_ * vec4(vertex_position, 1.0));
}




@OpenGL2.Fragment
#version 120

#define cubemap texture0

//Uniforms
uniform samplerCube texture0;
uniform vec4 Color=vec4(1,1,1,1);//expose color
uniform vec3 cameraposition;
uniform mat3 camerainversenormalmatrix;

//Inputs
varying vec2 ex_texcoords0;
varying vec3 ex_normal;
varying vec3 ex_tangent;
varying vec3 ex_binormal;
varying vec4 ex_color;
varying vec3 ex_vertexposition;

void main(void)
{
	gl_FragColor = Color * textureCube(cubemap,normalize( ex_vertexposition - cameraposition ));
}
