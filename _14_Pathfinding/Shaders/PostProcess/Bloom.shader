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
<<<<<<< .mine
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
        /*bloom += texture2D(texture2,ex_texcoords0 + vec2(box,0.0));
        bloom += texture2D(texture2,ex_texcoords0 + vec2(-box,0.0));
        bloom += texture2D(texture2,ex_texcoords0 + vec2(0.0,boy));
        bloom += texture2D(texture2,ex_texcoords0 + vec2(0.0,-boy));
        bloom += texture2D(texture2,ex_texcoords0 + vec2(box,boy));
        bloom += texture2D(texture2,ex_texcoords0 + vec2(-box,boy));
        bloom += texture2D(texture2,ex_texcoords0 + vec2(-box,-boy));
        bloom += texture2D(texture2,ex_texcoords0 + vec2(box,-boy));
        bloom /= 9.0;*/
        bloom.a = 0.0;
	
	/*
	float bloomthreshold = 0.65;
        float bloompower = 4.0;
	//float l = bloom.r * 0.2125 + bloom.g * 0.7154 + bloom.b * 0.0721;
        float l = max(max(bloom.r,bloom.g),bloom.b);
	
	if (l>0.0)
        {
		float ml = max(0.0, l-bloomthreshold) * bloompower;
		bloom.r *= ml / l;
		bloom.g *= ml / l;
		bloom.b *= ml / l;
        }
	gl_FragColor = outcolor + bloom;
	*/
		
	vec4 dst = texture2D(texture0, ex_texcoords0); // rendered scene
	vec4 src = texture2D(texture2, ex_texcoords0); // glowmap
	src = (src * 0.5) + 0.5;
	float dsti = dst.r * 0.2125 + dst.g * 0.7154 + dst.b * 0.0721;
	float srci = src.r * 0.2125 + src.g * 0.7154 + src.b * 0.0721;
	for (int i=0; i<4; i++)
	{
		if (src[i] <= 0.5)
		{
			gl_FragColor[i] = dst[i] - (1.0 - 2.0 * src[i]) * dst[i] * (1.0 - dst[i]);
		}
		else if ((src[i] > 0.5) && (dst[i] <= 0.25))
		{
			gl_FragColor[i] = dst[i] + (2.0 * src[i] - 1.0) * (4.0 * dst[i] * (4.0 * dst[i] + 1.0) * (dst[i] - 1.0) + 7.0 * dst[i]);
		}
		else
		{
			gl_FragColor[i] = dst[i] + (2.0 * src[i] - 1.0) * (sqrt(dst[i]));
		}
	}
	

float bloomthreshold = 0.75;
        float bloompower = 1.0;

//bloom = max(0.0, bloom - 0.25);
bloom = bloom * bloom * bloompower;
//bloom = max(src - bloomthreshold,0)*bloompower;
gl_FragColor = dst + bloom;
	
        //gl_FragColor.xyz = vec3((src.x <= 0.5) ? (dst.x - (1.0 - 2.0 * src.x) * dst.x * (1.0 - dst.x)) : (((src.x > 0.5) && (dst.x <= 0.25)) ? (dst.x + (2.0 * src.x - 1.0) * (4.0 * dst.x * (4.0 * dst.x + 1.0) * (dst.x - 1.0) + 7.0 * dst.x)) : (dst.x + (2.0 * src.x - 1.0) * (sqrt(dst.x) - dst.x))),
          //          (src.y <= 0.5) ? (dst.y - (1.0 - 2.0 * src.y) * dst.y * (1.0 - dst.y)) : (((src.y > 0.5) && (dst.y <= 0.25)) ? (dst.y + (2.0 * src.y - 1.0) * (4.0 * dst.y * (4.0 * dst.y + 1.0) * (dst.y - 1.0) + 7.0 * dst.y)) : (dst.y + (2.0 * src.y - 1.0) * (sqrt(dst.y) - dst.y))),
            //        (src.z <= 0.5) ? (dst.z - (1.0 - 2.0 * src.z) * dst.z * (1.0 - dst.z)) : (((src.z > 0.5) && (dst.z <= 0.25)) ? (dst.z + (2.0 * src.z - 1.0) * (4.0 * dst.z * (4.0 * dst.z + 1.0) * (dst.z - 1.0) + 7.0 * dst.z)) : (dst.z + (2.0 * src.z - 1.0) * (sqrt(dst.z) - dst.z))));
       // gl_FragColor.w = 1.0;

        //
	//gl_FragColor = bloom;
=======
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
>>>>>>> .r1627
}
@OpenGLES2.Vertex
<<<<<<< .mine
uniform mediump mat4 projectionmatrix;
uniform mediump mat4 drawmatrix;
uniform mediump vec2 offset;

attribute mediump vec3 vertex_position;
attribute mediump vec2 vertex_texcoords0;

varying mediump vec2 ex_texcoords0;

void main(void)
{
	gl_Position = projectionmatrix * (drawmatrix * vec4(vertex_position, 1.0) + vec4(offset,0,0));
	ex_texcoords0 = vertex_texcoords0;
=======
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
>>>>>>> .r1627
}
@OpenGLES2.Fragment
<<<<<<< .mine
uniform sampler2D texture0;
uniform mediump vec2 buffersize;
uniform mediump vec4 drawcolor;

varying mediump vec2 ex_texcoords0;

void main(void)
{
	gl_FragData[0] = texture2D(texture0,ex_texcoords0) * drawcolor;
=======
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
>>>>>>> .r1627
}
