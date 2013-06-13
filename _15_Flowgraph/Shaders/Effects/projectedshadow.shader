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
varying vec4 ex_vertexposition;

void main()
{
	mat4 entitymatrix_=entitymatrix;
	entitymatrix_[0][3]=0.0;
	entitymatrix_[1][3]=0.0;
	entitymatrix_[2][3]=0.0;
	entitymatrix_[3][3]=1.0;
	
	ex_vertexposition = entitymatrix_ * vec4(vertex_position, 1.0);

//#ifdef __GLSL_CG_DATA_TYPES
//	gl_ClipVertex = ex_vertexposition;
//#endif

	ex_VertexCameraPosition = vec3(camerainversematrix * ex_vertexposition);
	gl_Position = projectioncameramatrix * entitymatrix_ * vec4(vertex_position, 1.0);
	//gl_Position.z *= 0.999;
	
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
uniform mat4 shadowprojectionmatrix;
uniform vec4 ambientlight;
uniform vec4 shadowplane;
uniform float shadowdistance;
uniform mat4 projectedshadowmappingmatrix;

//Inputs
//varying vec2 ex_texcoords0;
varying vec2 ex_texcoords1;
varying vec4 ex_color;
varying float ex_selectionstate;
varying vec3 ex_VertexCameraPosition;
varying vec3 ex_normal;
varying vec4 ex_vertexposition;

void main(void)
{
	vec4 pos = projectedshadowmappingmatrix * ex_vertexposition;	
	vec3 ex_texcoords0;
	ex_texcoords0.x = pos.x + 0.5;
	ex_texcoords0.y = 1.0 - (pos.y + 0.5);
	
	//It's a good idea to leave these discards in, since brushes don't presently get split up:
	if (ex_texcoords0.x<0.0) discard;
	if (ex_texcoords0.y<0.0) discard;
	if (ex_texcoords0.x>1.0) discard;
	if (ex_texcoords0.y>1.0) discard;
	
	vec4 outcolor = ex_color;
	vec4 color_specular = materialcolorspecular;
	float texturewidth0 = 64.0;
	
	vec2 coords = ex_texcoords0.xy;
	outcolor = texture2D(texture0,coords );
	
	coords.x = ex_texcoords0.x + 1.0/texturewidth0;
	outcolor += texture2D(texture0,coords );
	coords.x = ex_texcoords0.x - 1.0/texturewidth0;
	outcolor += texture2D(texture0,coords );
	coords.x = ex_texcoords0.x;	
	coords.y = ex_texcoords0.y + 1.0/texturewidth0;
	outcolor += texture2D(texture0,coords );
	coords.y = ex_texcoords0.y - 1.0/texturewidth0;
	outcolor += texture2D(texture0,coords );
	
	coords += ex_texcoords0.xy;
	coords.x = ex_texcoords0.x + 1.0/texturewidth0;
	coords.y = ex_texcoords0.y + 1.0/texturewidth0;
	outcolor += texture2D(texture0,coords );
	coords.x = ex_texcoords0.x - 1.0/texturewidth0;
	coords.y = ex_texcoords0.y + 1.0/texturewidth0;
	outcolor += texture2D(texture0,coords );
	coords.x = ex_texcoords0.x + 1.0/texturewidth0;
	coords.y = ex_texcoords0.y - 1.0/texturewidth0;
	outcolor += texture2D(texture0,coords );
	coords.x = ex_texcoords0.x - 1.0/texturewidth0;
	coords.y = ex_texcoords0.y - 1.0/texturewidth0;
	outcolor += texture2D(texture0,coords );
	outcolor /= 9.0;

	if (outcolor.r>0.999) discard;
		
	outcolor = 1.0 - outcolor;
	float a = (pos.z-0.5)/0.5;
	a = 1.0 - clamp(a,0.0,1.0);
	outcolor *= a;
	outcolor = 1.0 - outcolor;
	
	//outcolor.r = max(outcolor.r,lighting_ambient.r);
	//outcolor.g = max(outcolor.g,lighting_ambient.g);
	//outcolor.b = max(outcolor.b,lighting_ambient.b);
	outcolor.r = max(outcolor.r,0.5);
	outcolor.g = max(outcolor.g,0.5);
	outcolor.b = max(outcolor.b,0.5);	
	
	gl_FragColor = outcolor;
	
	//gl_FragColor = vec4(1.0,0.0,0.0,1.0);
	/*
	if (ex_texcoords0.x<0.0) gl_FragColor = vec4(1.0,0.0,0.0,1.0);
	if (ex_texcoords0.y<0.0) gl_FragColor = vec4(1.0,0.0,0.0,1.0);
	if (ex_texcoords0.x>1.0) gl_FragColor = vec4(1.0,0.0,0.0,1.0);
	if (ex_texcoords0.y>1.0) gl_FragColor = vec4(1.0,0.0,0.0,1.0);
	*/
}
@OpenGLES2.Vertex
precision highp float;

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
varying vec4 ex_vertexposition;

void main()
{
	mat4 entitymatrix_=entitymatrix;
	entitymatrix_[0][3]=0.0;
	entitymatrix_[1][3]=0.0;
	entitymatrix_[2][3]=0.0;
	entitymatrix_[3][3]=1.0;
	
	ex_vertexposition = entitymatrix_ * vec4(vertex_position, 1.0);

//#ifdef __GLSL_CG_DATA_TYPES
//	gl_ClipVertex = ex_vertexposition;
//#endif

	ex_VertexCameraPosition = vec3(camerainversematrix * ex_vertexposition);
	gl_Position = projectioncameramatrix * entitymatrix_ * vec4(vertex_position, 1.0);
	//gl_Position.z *= 0.999;
	
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
@OpenGLES2.Fragment
precision highp float;

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
uniform mat4 shadowprojectionmatrix;
uniform vec4 ambientlight;
uniform vec4 shadowplane;
uniform float shadowdistance;
uniform mat4 projectedshadowmappingmatrix;

//Inputs
//varying vec2 ex_texcoords0;
varying vec2 ex_texcoords1;
varying vec4 ex_color;
varying float ex_selectionstate;
varying vec3 ex_VertexCameraPosition;
varying vec3 ex_normal;
varying vec4 ex_vertexposition;

void main(void)
{
	vec4 pos = projectedshadowmappingmatrix * ex_vertexposition;	
	vec3 ex_texcoords0;
	ex_texcoords0.x = pos.x + 0.5;
	ex_texcoords0.y = 1.0 - (pos.y + 0.5);
	
	/*
	if (ex_texcoords0.x<0.0) discard;
	if (ex_texcoords0.y<0.0) discard;
	if (ex_texcoords0.x>1.0) discard;
	if (ex_texcoords0.y>1.0) discard;
	*/
	
	vec4 outcolor = ex_color;
	vec4 color_specular = materialcolorspecular;
	float texturewidth0 = 64.0;
	
	vec2 coords = ex_texcoords0.xy;
	outcolor = texture2D(texture0,coords );
	
	coords.x = ex_texcoords0.x + 1.0/texturewidth0;
	outcolor += texture2D(texture0,coords );
	coords.x = ex_texcoords0.x - 1.0/texturewidth0;
	outcolor += texture2D(texture0,coords );
	coords.x = ex_texcoords0.x;	
	coords.y = ex_texcoords0.y + 1.0/texturewidth0;
	outcolor += texture2D(texture0,coords );
	coords.y = ex_texcoords0.y - 1.0/texturewidth0;
	outcolor += texture2D(texture0,coords );
	
	coords += ex_texcoords0.xy;
	coords.x = ex_texcoords0.x + 1.0/texturewidth0;
	coords.y = ex_texcoords0.y + 1.0/texturewidth0;
	outcolor += texture2D(texture0,coords );
	coords.x = ex_texcoords0.x - 1.0/texturewidth0;
	coords.y = ex_texcoords0.y + 1.0/texturewidth0;
	outcolor += texture2D(texture0,coords );
	coords.x = ex_texcoords0.x + 1.0/texturewidth0;
	coords.y = ex_texcoords0.y - 1.0/texturewidth0;
	outcolor += texture2D(texture0,coords );
	coords.x = ex_texcoords0.x - 1.0/texturewidth0;
	coords.y = ex_texcoords0.y - 1.0/texturewidth0;
	outcolor += texture2D(texture0,coords );
	outcolor /= 9.0;

	if (outcolor.r>0.999) discard;
		
	outcolor = 1.0 - outcolor;
	float a = (pos.z-0.5)/0.5;
	a = 1.0 - clamp(a,0.0,1.0);
	outcolor *= a;
	outcolor = 1.0 - outcolor;
	
	//outcolor.r = max(outcolor.r,lighting_ambient.r);
	//outcolor.g = max(outcolor.g,lighting_ambient.g);
	//outcolor.b = max(outcolor.b,lighting_ambient.b);
	outcolor.r = max(outcolor.r,0.5);
	outcolor.g = max(outcolor.g,0.5);
	outcolor.b = max(outcolor.b,0.5);	
	
	gl_FragData[0] = outcolor;
}
