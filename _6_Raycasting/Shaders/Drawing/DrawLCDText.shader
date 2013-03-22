SHADER version 1
@OpenGL2.Vertex
#version 120

uniform mat4 projectionmatrix;
uniform mat4 drawmatrix;
uniform vec2 offset;
uniform vec2 position[4];
uniform vec2 texcoords[4];
uniform vec2 drawoffset;

attribute vec3 vertex_position;

varying vec2 ex_texcoords0;

void main(void)
{
	mat4 drawmatrix_ = drawmatrix;
	drawmatrix_[3][0]+=drawoffset.x;
	drawmatrix_[3][1]+=drawoffset.y;
	int i = int(vertex_position.x);//gl_VertexID was implemented in GLSL 1.30, not available in 1.20.
	gl_Position = projectionmatrix * (drawmatrix_ * vec4(position[i], 1.0, 1.0));
	ex_texcoords0 = texcoords[i];
}
@OpenGL2.Fragment
#version 120

uniform vec4 drawcolor;
uniform sampler2D texture0;

varying vec2 ex_texcoords0;

void main(void)
{
	gl_FragColor = texture2D(texture0,ex_texcoords0) * drawcolor;
}
