SHADER version 1
@OpenGL2.Vertex
//Uniforms
uniform mat4 entitymatrix;
uniform vec4 materialcolordiffuse;
uniform mat4 projectioncameramatrix;
uniform mat4 camerainversematrix;

//Attributes
attribute vec3 vertex_position;
attribute vec4 vertex_color;
attribute vec2 vertex_texcoords0;
attribute vec2 vertex_texcoords1;
attribute vec3 vertex_normal;

//Outputs
varying vec4 ex_color;
varying vec2 ex_texcoords0;
varying vec2 ex_texcoords1;
varying float ex_selectionstate;
varying vec3 ex_VertexCameraPosition;
varying vec3 ex_normal;

void main()
{
	mat4 entitymatrix_=entitymatrix;
	entitymatrix_[0][3]=0.0;
	entitymatrix_[1][3]=0.0;
	entitymatrix_[2][3]=0.0;
	entitymatrix_[3][3]=1.0;
	
	vec4 modelvertexposition = entitymatrix_ * vec4(vertex_position,1.0);
	ex_VertexCameraPosition = vec3(camerainversematrix * modelvertexposition);
	gl_Position = projectioncameramatrix * modelvertexposition;

	mat3 nmat = mat3(camerainversematrix[0].xyz,camerainversematrix[1].xyz,camerainversematrix[2].xyz);//39
	nmat = nmat * mat3(entitymatrix[0].xyz,entitymatrix[1].xyz,entitymatrix[2].xyz);//40
	ex_normal = (nmat * vertex_normal);	

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
uniform sampler2D texture0;	
uniform int lightingmode;
uniform vec2 buffersize;
uniform vec2 camerarange;
uniform float camerazoom;
uniform vec4 materialcoloruniform;
uniform vec4 materialcolorspecular;
uniform vec4 lighting_ambient;

//Lighting
uniform vec3 lightdirection[4];
uniform vec4 lightcolor[4];
uniform vec4 lightposition[4];
uniform float lightrange[4];
uniform vec3 lightingcenter[4];
uniform vec2 lightingconeanglescos[4];
uniform vec4 lightspecular[4];

//Inputs
varying vec2 ex_texcoords0;
varying vec2 ex_texcoords1;
varying vec4 ex_color;
varying float ex_selectionstate;
varying vec3 ex_VertexCameraPosition;
varying vec3 ex_normal;

float DepthToZPosition(in float depth) {
	return camerarange.x / (camerarange.y - depth * (camerarange.y - camerarange.x)) * camerarange.y;
}

void main(void)
{
	vec4 outcolor = ex_color;
	vec4 color_specular = materialcolorspecular;
	
	outcolor *= texture2D(texture0,ex_texcoords0);
	
	vec3 screencoord = vec3(((gl_FragCoord.x/buffersize.x)-0.5) * 2.0 * (buffersize.x/buffersize.y),((-gl_FragCoord.y/buffersize.y)+0.5) * 2.0,DepthToZPosition( gl_FragCoord.z ));
	screencoord.x *= screencoord.z / camerazoom;
	screencoord.y *= -screencoord.z / camerazoom;   

	vec3 normal = ex_normal;

	//Calculate lighting
	vec4 lighting_diffuse = vec4(0);
	vec4 lighting_specular = vec4(0);
	float attenuation=1.0;
	vec3 lightdir;
	vec3 lightreflection;
	int i;
	float anglecos;
	float diffspotangle;	
	float denom;

	//One equation, three light types
	for (i=0; i<4; i++)
	{
		//Get light direction to this pixel
		lightdir = normalize(ex_VertexCameraPosition - lightposition[i].xyz) * lightposition[i].w + lightdirection[i] * (1.0 - lightposition[i].w);
		
		//Distance attenuation
		attenuation = lightposition[i].w * max(0.0, 1.0 - distance(lightposition[i].xyz,ex_VertexCameraPosition) / lightrange[i]) + (1.0 - lightposition[i].w);
		
		//Normal attenuation
		attenuation *= max(0.0,dot(normal,-lightdir));
		
		//Spot cone attenuation
		denom = lightingconeanglescos[i].y-lightingconeanglescos[i].x;	
		if (denom>-1.0)
		{
			anglecos = max(0.0,dot(lightdirection[i],lightdir));
			attenuation *= 1.0 - clamp((lightingconeanglescos[i].y-anglecos)/denom,0.0,1.0);
		}

		lighting_diffuse += lightcolor[i] * attenuation;
	}
	
	outcolor = (lighting_diffuse + lighting_ambient) * outcolor;	
	
	//Blend with selection color if selected
	gl_FragColor = outcolor * (1.0-ex_selectionstate) + ex_selectionstate * (outcolor*0.5+vec4(0.5,0.0,0.0,0.0));
}
@OpenGLES2.Vertex
//Uniforms
uniform mediump mat4 camerainversematrix;
uniform mediump mat4 projectioncameramatrix;
uniform mediump mat4 entitymatrix;
uniform mediump vec4 materialcolor;
uniform mediump mat4 cameramatrix;

//Attributes
attribute mediump vec3 vertex_position;
attribute mediump vec3 vertex_normal;
attribute mediump vec4 vertex_color;
attribute mediump vec2 vertex_texcoords0;
attribute mediump vec3 vertex_binormal;
attribute mediump vec3 vertex_tangent;

//Outputs
varying mediump vec4 ex_color;
varying mediump vec2 ex_texcoords0;
varying mediump vec3 ex_normal;
varying mediump vec3 ex_tangent;
varying mediump vec3 ex_binormal;
varying mediump vec3 ex_vertexposition;
varying mediump vec3 ex_motion;
varying mediump vec3 ex_eyevec;
varying mediump vec4 vertexcameraposition;
varying mediump vec3 VertexCameraPosition;

void main(void)
{
	mat4 entitymatrix_=entitymatrix;
	entitymatrix_[0][3]=0.0;
	entitymatrix_[1][3]=0.0;
	entitymatrix_[2][3]=0.0;
	entitymatrix_[3][3]=1.0;
	
	vertexcameraposition = projectioncameramatrix * entitymatrix_ * vec4(vertex_position, 1.0);
	gl_Position = vertexcameraposition;
	//VertexCameraPosition = vec3(camerainversematrix * entitymatrix_ * vec4(vertex_position, 1.0));
    
	mat3 nmat = mat3(camerainversematrix[0].xyz,camerainversematrix[1].xyz,camerainversematrix[2].xyz);
	nmat = nmat * mat3(entitymatrix[0].xyz,entitymatrix[1].xyz,entitymatrix[2].xyz);
	
	ex_normal = normalize(nmat * vertex_normal);
	//ex_tangent = normalize(nmat * vertex_tangent);
	//ex_binormal = normalize(nmat * vertex_binormal);
	
	ex_color = vec4(entitymatrix[0][3],entitymatrix[1][3],entitymatrix[2][3],entitymatrix[3][3]);// * materialcolor;
	
	ex_texcoords0 = vertex_texcoords0;
	
	ex_vertexposition = vec3(entitymatrix_ * vec4(vertex_position, 1.0));
	
	//Parallax
	//ex_eyevec.x = dot(gl_Position.xyz, ex_tangent);
	//ex_eyevec.y = dot(gl_Position.xyz, ex_binormal);
	//ex_eyevec.z = dot(gl_Position.xyz, ex_normal);
	//ex_eyevec = normalize(ex_eyevec);
	
	//mat3 tbnmat;
	//tbnmat[0] = ex_tangent;
	//tbnmat[1] = ex_binormal;
	//tbnmat[2] = ex_normal;
	//ex_eyevec = -vec3(cameramatrix*vec4(ex_vertexposition.xyz,1)) * tbnmat;	
}
@OpenGLES2.Fragment
//Uniforms
uniform sampler2D texture0;
uniform highp vec2 buffersize;
uniform highp vec2 camerarange;
uniform highp float camerazoom;
uniform highp vec4 materialcoloruniform;
uniform highp vec4 materialcolorspecular;
uniform highp vec4 lighting_ambient;

#define MAXLIGHTS 2

//Lighting
uniform highp vec3 lightdirection[MAXLIGHTS];
uniform highp vec4 lightcolor[MAXLIGHTS];
uniform highp vec4 lightposition[MAXLIGHTS];
uniform highp float lightrange[MAXLIGHTS];
uniform highp vec3 lightingcenter[MAXLIGHTS];
uniform highp vec2 lightingconeanglescos[MAXLIGHTS];
uniform highp vec4 lightspecular[MAXLIGHTS];

//Inputs
varying highp vec2 ex_texcoords0;
varying highp vec2 ex_texcoords1;
varying highp vec4 ex_color;
varying highp vec3 ex_VertexCameraPosition;
varying highp vec3 ex_normal;

void main(void)
{
	highp vec4 outcolor = ex_color;
	highp vec4 color_specular = materialcolorspecular;
	highp vec3 normal = ex_normal;
	
	outcolor *= texture2D(texture0,ex_texcoords0);

	//Calculate lighting
	highp vec4 lighting_diffuse = vec4(0);
	highp vec4 lighting_specular = vec4(0);
	highp float attenuation=1.0;
	highp vec3 lightdir;
	highp vec3 lightreflection;
	int i;
	highp float anglecos;
	highp float diffspotangle;	
	highp float denom;
	
	//One equation, three light types
	for (i=0; i<MAXLIGHTS; i++)
	{
		//Get light direction to this pixel
		lightdir = normalize(ex_VertexCameraPosition - lightposition[i].xyz) * lightposition[i].w + lightdirection[i] * (1.0 - lightposition[i].w);
		
		//Distance attenuation
		attenuation = lightposition[i].w * max(0.0, 1.0 - distance(lightposition[i].xyz,ex_VertexCameraPosition) / lightrange[i]) + (1.0 - lightposition[i].w);
		
		//Normal attenuation
		attenuation *= max(0.0,dot(normal,-lightdir));
		
		//Spot cone attenuation
		denom = lightingconeanglescos[i].y-lightingconeanglescos[i].x;	
		if (denom>-1.0)
		{
			anglecos = max(0.0,dot(lightdirection[i],lightdir));
			attenuation *= 1.0 - clamp((lightingconeanglescos[i].y-anglecos)/denom,0.0,1.0);
		}

		lighting_diffuse += lightcolor[i] * attenuation;
	}
	
	//Blend with selection color if selected
	gl_FragData[0] = (lighting_diffuse + lighting_ambient) * outcolor;
}
