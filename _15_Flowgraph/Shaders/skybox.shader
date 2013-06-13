SHADER version 1
@OpenGL2.Vertex
//Uniforms
uniform mat4 entitymatrix;
uniform vec4 materialcolordiffuse;
uniform mat4 cameramatrix;
uniform mat4 camerainversematrix;
uniform mat4 projectioncameramatrix;

//Attributes
attribute vec3 vertex_position;
attribute vec4 vertex_color;
attribute vec2 vertex_texcoords0;
attribute vec2 vertex_texcoords1;
attribute vec3 vertex_normal;
attribute vec3 vertex_tangent;
attribute vec3 vertex_binormal;

//Outputs
varying vec4 ex_vertexposition;
varying vec4 ex_color;
varying vec2 ex_texcoords0;
varying vec2 ex_texcoords1;
varying float ex_selectionstate;
varying vec3 ex_normal;
varying vec3 ex_tangent;
varying vec3 ex_binormal;

void main()
{
	mat4 entitymatrix_=entitymatrix;
	entitymatrix_[0][3]=0.0;
	entitymatrix_[1][3]=0.0;
	entitymatrix_[2][3]=0.0;
	entitymatrix_[3][3]=1.0;
	
	ex_vertexposition = entitymatrix_ * vec4(vertex_position, 1.0);
	gl_Position = projectioncameramatrix * ex_vertexposition;
	
	ex_texcoords0 = vertex_texcoords0;
	ex_texcoords1 = vertex_texcoords1;
	
	ex_color = vec4(entitymatrix[0][3],entitymatrix[1][3],entitymatrix[2][3],entitymatrix[3][3]);
	
	//If an object is selected, 10 is subtracted from the alpha color.
	//This is a bit of a hack that packs a per-object boolean into the alpha value.
	ex_selectionstate = 0.0;
	if (ex_color.a<-5.0)
	{
		ex_color.a += 10.0;
		ex_selectionstate = 1.0;
	}
	ex_color *= vec4(1.0-vertex_color.r,1.0-vertex_color.g,1.0-vertex_color.b,vertex_color.a) * materialcolordiffuse;
}
@OpenGL2.Fragment
//Uniforms	
uniform samplerCube texture0;//cube map
uniform vec3 cameraposition;

//Inputs
varying vec4 ex_vertexposition;
varying float ex_selectionstate;

void main(void)
{
	vec3 cubecoord = normalize( ex_vertexposition.xyz - cameraposition );
	vec4 outcolor = textureCube(texture0,cubecoord);
	gl_FragColor = outcolor * (1.0-ex_selectionstate) + ex_selectionstate * (outcolor*0.5+vec4(0.5,0.0,0.0,0.0));
}
@OpenGLES2.Vertex

@OpenGLES2.Fragment

