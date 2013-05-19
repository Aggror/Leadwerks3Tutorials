SHADER version 1
@OpenGL2.Vertex
uniform mat4 projectionmatrix;
uniform mat4 drawmatrix;
uniform vec2 offset;
uniform vec2 position[4];
uniform vec2 texcoords[4];

attribute vec3 vertex_position;

varying vec2 ex_texcoords0;

void main(void)
{
	int i = int(vertex_position.x);//gl_VertexID was implemented in GLSL 1.30, not available in 1.20.
	gl_Position = projectionmatrix * (drawmatrix * vec4(position[i], 1.0, 1.0));
	ex_texcoords0 = texcoords[i];
}
@OpenGL2.Fragment
uniform vec4 drawcolor;

uniform vec2 blurbuffersize;

//Screen diffuse
uniform sampler2D texture0;

//Bloom texture
uniform sampler2D texture2;

//Shadow camera matrix
uniform vec2 gbuffersize;
uniform float camerazoom;
uniform vec2 camerarange;
uniform vec3 lightdir;
uniform mat4 camerainversematrix;
uniform mat4 camimat;
uniform vec3 campos;

varying vec2 ex_texcoords0;

void main(void)
{
	float ambient = 0.125;
	
        //Get diffuse color
        vec4 outcolor = texture2D(texture0,ex_texcoords0);
        
        vec4 bloom = texture2D(texture2,ex_texcoords0);
	vec4 obloom = bloom;
        float box = 1.0 / (blurbuffersize.x);
        float boy = 1.0 / (blurbuffersize.y);
        bloom.a = 0.0;
	
	vec4 dst = texture2D(texture0, ex_texcoords0); // rendered scene
	vec4 src = texture2D(texture2, ex_texcoords0); // glowmap
	src = (src * 0.5) + 0.5;
	float bloomthreshold = 0.75;
        float bloompower = 2.0;
	bloom = bloom * bloom * bloompower;
	gl_FragColor = dst + bloom;
}
@OpenGLES2.Vertex
precision highp float;

uniform mat4 projectionmatrix;
uniform mat4 drawmatrix;
uniform vec2 offset;

attribute vec3 vertex_position;
attribute vec2 vertex_texcoords0;

varying vec2 ex_texcoords0;

void main(void)
{
	gl_Position = projectionmatrix * (drawmatrix * vec4(vertex_position, 1.0) + vec4(offset,0,0));
	ex_texcoords0 = vertex_texcoords0;
}
@OpenGLES2.Fragment
precision highp float;

uniform vec4 drawcolor;

uniform vec2 blurbuffersize;

//Screen diffuse
uniform sampler2D texture0;

//Bloom texture
uniform sampler2D texture2;

//Shadow camera matrix
uniform vec2 gbuffersize;
uniform float camerazoom;
uniform vec2 camerarange;
uniform vec3 lightdir;
uniform mat4 camerainversematrix;
uniform mat4 camimat;
uniform vec3 campos;

varying vec2 ex_texcoords0;

void main(void)
{
	float ambient = 0.125;
        vec4 outcolor = texture2D(texture0,ex_texcoords0);
        vec4 bloom = texture2D(texture2,ex_texcoords0);
	//vec4 obloom = bloom;
        //float box = 1.0 / (blurbuffersize.x);
        //float boy = 1.0 / (blurbuffersize.y);
        bloom.a = 0.0;	
	//vec4 dst = texture2D(texture0, ex_texcoords0); // rendered scene
	//vec4 src = texture2D(texture2, ex_texcoords0); // glowmap
	//src = (src * 0.5) + 0.5;
	//float dsti = dst.r * 0.2125 + dst.g * 0.7154 + dst.b * 0.0721;
	//float srci = src.r * 0.2125 + src.g * 0.7154 + src.b * 0.0721;
	float bloomthreshold = 0.75;
	float bloompower = 4.0;
	bloom = bloom * bloom * bloompower;
	gl_FragColor = outcolor + bloom;
}
