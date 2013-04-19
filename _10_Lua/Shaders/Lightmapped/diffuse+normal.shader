SHADER version 1
@OpenGL2.Vertex
#version 120

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
	
	gl_Position = projectioncameramatrix * entitymatrix_ * vec4(vertex_position, 1.0);
	
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
	
	//Transform vectors from local to global space
	mat3 nmat = mat3(camerainversematrix) * mat3(entitymatrix);
	ex_normal = normalize(nmat * vertex_normal);	
	ex_tangent = normalize(nmat * vertex_tangent);
	ex_binormal = normalize(nmat * vertex_binormal);
}
@OpenGL2.Fragment
#version 120

//Uniforms	
uniform sampler2D texture0;//diffuse map
uniform sampler2D texture1;//normal map
uniform sampler2D texture3;//light map
uniform sampler2D texture4;//light vector map
uniform mat4 cameramatrix;
uniform mat4 projectioncameramatrix;
uniform vec2 camerarange;
uniform float camerazoom;
uniform vec2 buffersize;
uniform mat4 camerainversematrix;
uniform vec4 ambientlight;

//Inputs
varying vec2 ex_texcoords0;
varying vec2 ex_texcoords1;
varying vec4 ex_color;
varying float ex_selectionstate;
varying vec3 ex_normal;
varying vec3 ex_tangent;
varying vec3 ex_binormal;

void main(void)
{
	vec4 outcolor = ex_color;
	
	//Modulate blend with diffuse map
	outcolor *= texture2D(texture0,ex_texcoords0);
	
	//Mod2X blend with light map
	vec4 lighting_diffuse = texture2D(texture3,ex_texcoords1) * 2.0;
	lighting_diffuse.a = 1.0;
	
	//Average light direction vector
	vec4 lightvec = texture2D(texture4,ex_texcoords1);
	vec3 lightdir = (lightvec.xyz * 2.0 - 1.0) * lightvec.a + -ex_normal * (1.0 - lightvec.a);
	lightdir = mat3(camerainversematrix) * lightdir;
	lightdir = normalize(lightdir);
	
	//Normal map
	vec3 normal = ex_normal;
	normal = normalize(texture2D(texture1,ex_texcoords0).ywz * 2.0 - 1.0);
	normal = ex_tangent * normal.x + ex_binormal * normal.y + ex_normal * normal.z;	
	
	//Lighting
	float attenuation = clamp(dot(normal,-lightdir),0.0,1.0);
	
	//Final lighting calculation
	outcolor = outcolor * ambientlight + outcolor * attenuation * lighting_diffuse;
	
	//Blend with selection color if selected
	gl_FragColor = outcolor * (1.0-ex_selectionstate) + ex_selectionstate * (outcolor*0.5+vec4(0.5,0.0,0.0,0.0));
}
@OpenGLES2.Vertex
precision highp float;

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
	
	gl_Position = projectioncameramatrix * entitymatrix_ * vec4(vertex_position, 1.0);
	
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
	
	//Transform vectors from local to global space
	mat3 nmat = mat3(camerainversematrix) * mat3(entitymatrix);
	ex_normal = normalize(nmat * vertex_normal);	
	ex_tangent = normalize(nmat * vertex_tangent);
	ex_binormal = normalize(nmat * vertex_binormal);
}
@OpenGLES2.Fragment
precision highp float;

//Uniforms	
uniform sampler2D texture0;//diffuse map
uniform sampler2D texture1;//normal map
uniform sampler2D texture3;//light map
uniform sampler2D texture4;//light vector map
uniform mat4 cameramatrix;
uniform mat4 projectioncameramatrix;
uniform vec2 camerarange;
uniform float camerazoom;
uniform vec2 buffersize;
uniform mat4 camerainversematrix;
uniform vec4 ambientlight;

//Inputs
varying vec2 ex_texcoords0;
varying vec2 ex_texcoords1;
varying vec4 ex_color;
varying float ex_selectionstate;
varying vec3 ex_normal;
varying vec3 ex_tangent;
varying vec3 ex_binormal;

void main(void)
{
	vec4 outcolor = ex_color;
	
	//Modulate blend with diffuse map
	outcolor *= texture2D(texture0,ex_texcoords0);
	
	//Mod2X blend with light map
	vec4 lighting_diffuse = texture2D(texture3,ex_texcoords1) * 2.0;
	lighting_diffuse.a = 1.0;
	
	//Average light direction vector
	vec4 lightvec = texture2D(texture4,ex_texcoords1);
	vec3 lightdir = (lightvec.xyz * 2.0 - 1.0) * lightvec.a + -ex_normal * (1.0 - lightvec.a);
	lightdir = mat3(camerainversematrix) * lightdir;
	lightdir = normalize(lightdir);
	
	//Normal map
	vec3 normal = ex_normal;
	normal = normalize(texture2D(texture1,ex_texcoords0).ywz * 2.0 - 1.0);
	normal = ex_tangent * normal.x + ex_binormal * normal.y + ex_normal * normal.z;	
	
	//Lighting
	float attenuation = clamp(dot(normal,-lightdir),0.0,1.0);
	
	//Final lighting calculation
	outcolor = outcolor * ambientlight + outcolor * attenuation * lighting_diffuse;
	
	//Blend with selection color if selected
	gl_FragColor = outcolor * (1.0-ex_selectionstate) + ex_selectionstate * (outcolor*0.5+vec4(0.5,0.0,0.0,0.0));
}
