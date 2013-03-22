SHADER version 1
@OpenGL2.Vertex
//Uniforms
uniform mat4 camerainversematrix;
uniform mat4 projectioncameramatrix;
uniform mat4 entitymatrix;
uniform vec4 materialcolordiffuse;
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
varying vec3 ex_normal;

void main(void)
{
	mat4 entitymatrix_=entitymatrix;
	entitymatrix_[0][3]=0.0;
	entitymatrix_[1][3]=0.0;
	entitymatrix_[2][3]=0.0;
	entitymatrix_[3][3]=1.0;
	
	ex_color = vec4(entitymatrix[0][3],entitymatrix[1][3],entitymatrix[2][3],entitymatrix[3][3]);
	
	gl_Position = projectioncameramatrix * entitymatrix_ * vec4(vertex_position, 1.0);
    	
	mat3 nmat = mat3(camerainversematrix[0].xyz,camerainversematrix[1].xyz,camerainversematrix[2].xyz);
	nmat = nmat * mat3(entitymatrix[0].xyz,entitymatrix[1].xyz,entitymatrix[2].xyz);
	
	ex_normal = normalize(nmat * vertex_normal);
	
#ifdef __GLSL_CG_DATA_TYPES
	gl_ClipVertex = entitymatrix_ * vec4(vertex_position, 1.0);
#endif
}
@OpenGL2.Fragment
uniform int cameraprojectionmode;
uniform int cameradrawmode;
uniform mat4 camerainversematrix;
uniform mat4 entitymatrix;

varying vec4 ex_color;
varying vec3 ex_normal;

void main(void)
{
	vec3 lightdir = vec3(-1,-1,-1.5);
	vec4 outcolor = ex_color;
	if (cameradrawmode==4)
	{
		mat4 entitymatrix_ = entitymatrix;
		entitymatrix_[0][3] = 0.0;
		entitymatrix_[1][3] = 0.0;
		entitymatrix_[2][3] = 0.0;
		entitymatrix_[3][3] = 1.0;
		
		mat3 nmat = mat3(camerainversematrix[0].xyz,camerainversematrix[1].xyz,camerainversematrix[2].xyz);
		nmat = nmat * mat3(entitymatrix[0].xyz,entitymatrix[1].xyz,entitymatrix[2].xyz);
		lightdir = nmat * lightdir;
		lightdir = normalize(lightdir);
		float shading = max(0,dot(ex_normal,lightdir.xyz));
		shading += max(0,dot(ex_normal,-lightdir.xyz)*0.5);
		outcolor = outcolor * (1.0 + (shading-0.5) * 0.5);
	}
	gl_FragColor = outcolor;
}

