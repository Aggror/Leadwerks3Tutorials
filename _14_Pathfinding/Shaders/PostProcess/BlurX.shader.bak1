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
//#version 120

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
uniform vec2 buffersize;
uniform vec2 orientation;

varying vec2 ex_texcoords0;

float Gaussian (float x, float deviation)
{
    return (1.0 / sqrt(2.0 * 3.141592 * deviation)) * exp(-((x * x) / (2.0 * deviation)));  
}

void main(void)
{
	float BlurStrength=0.2;
	float halfBlur = 12.0 * 0.5;
	vec4 colour = vec4(0.0);
	vec4 texColour = vec4(0.0);
	
	// Gaussian deviation
	float deviation = halfBlur * 0.35;
	deviation *= deviation;
	float strength = 1.0 - BlurStrength;
	float gauss;
	
	vec2 texelsize = vec2(1.0) / buffersize;
	
        //for (int i=0; i<12+1; ++i)
	for (int i=0; i<12+1; i+=2)
        {
		float offset = float(i) - halfBlur;
		gauss = Gaussian(offset * strength, deviation);
		texColour = texture2D(texture0, ex_texcoords0 + vec2(offset*texelsize.x,offset*texelsize.y)*orientation) * gauss;
		colour += texColour;
        }

	gl_FragColor = colour;

	/*
	float box = 1.0 / buffersize.x;
        vec4 outcolor = texture2D(texture0,vec2(ex_texcoords0.x-box*5.0,ex_texcoords0.y));
	outcolor += texture2D(texture0,vec2(ex_texcoords0.x-box*4.0,ex_texcoords0.y));
	outcolor += texture2D(texture0,vec2(ex_texcoords0.x-box*3.0,ex_texcoords0.y));
	outcolor += texture2D(texture0,vec2(ex_texcoords0.x-box*2.0,ex_texcoords0.y));
	outcolor += texture2D(texture0,vec2(ex_texcoords0.x-box*1.0,ex_texcoords0.y));
	outcolor += texture2D(texture0,vec2(ex_texcoords0.x+box*1.0,ex_texcoords0.y));
	outcolor += texture2D(texture0,vec2(ex_texcoords0.x+box*2.0,ex_texcoords0.y));
	outcolor += texture2D(texture0,vec2(ex_texcoords0.x+box*3.0,ex_texcoords0.y));
	outcolor += texture2D(texture0,vec2(ex_texcoords0.x+box*4.0,ex_texcoords0.y));
	outcolor += texture2D(texture0,vec2(ex_texcoords0.x+box*5.0,ex_texcoords0.y));
	outcolor += texture2D(texture0,ex_texcoords0);
	
	gl_FragColor = outcolor / 11.0;*/
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
uniform vec2 buffersize;
uniform vec2 orientation;

varying vec2 ex_texcoords0;

float Gaussian (float x, float deviation)
{
    return (1.0 / sqrt(2.0 * 3.141592 * deviation)) * exp(-((x * x) / (2.0 * deviation)));  
}

void main(void)
{
	float BlurStrength=0.2;
	float halfBlur = 8.0 * 0.5;
	vec4 colour = vec4(0.0);
	vec4 texColour = vec4(0.0);
	
	// Gaussian deviation
	float deviation = halfBlur * 0.35;
	deviation *= deviation;
	float strength = 1.0 - BlurStrength;
	float gauss;
	
	vec2 texelsize = vec2(1.0) / buffersize;
	
        for (int i=0; i<8+1; ++i)
        {
		float offset = float(i) - halfBlur;
		gauss = Gaussian(offset * strength, deviation);
		texColour = texture2D(texture0, ex_texcoords0 + vec2(offset*texelsize.x,offset*texelsize.y)*orientation) * gauss;
		colour += texColour;
        }

	gl_FragColor = colour;
	
	//gl_FragColor = texture2D(texture0,ex_texcoords0);
	
	/*
	float box = 1.0 / buffersize.x;
        vec4 outcolor = texture2D(texture0,vec2(ex_texcoords0.x-box*5.0,ex_texcoords0.y));
	outcolor += texture2D(texture0,vec2(ex_texcoords0.x-box*4.0,ex_texcoords0.y));
	outcolor += texture2D(texture0,vec2(ex_texcoords0.x-box*3.0,ex_texcoords0.y));
	outcolor += texture2D(texture0,vec2(ex_texcoords0.x-box*2.0,ex_texcoords0.y));
	outcolor += texture2D(texture0,vec2(ex_texcoords0.x-box*1.0,ex_texcoords0.y));
	outcolor += texture2D(texture0,vec2(ex_texcoords0.x+box*1.0,ex_texcoords0.y));
	outcolor += texture2D(texture0,vec2(ex_texcoords0.x+box*2.0,ex_texcoords0.y));
	outcolor += texture2D(texture0,vec2(ex_texcoords0.x+box*3.0,ex_texcoords0.y));
	outcolor += texture2D(texture0,vec2(ex_texcoords0.x+box*4.0,ex_texcoords0.y));
	outcolor += texture2D(texture0,vec2(ex_texcoords0.x+box*5.0,ex_texcoords0.y));
	outcolor += texture2D(texture0,ex_texcoords0);
	
	gl_FragColor = outcolor / 11.0;*/
}
