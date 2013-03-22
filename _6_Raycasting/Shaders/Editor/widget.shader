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
varying vec2 ex_texcoords0;
varying vec3 ex_normal;
varying vec3 ex_tangent;
varying vec3 ex_binormal;
varying vec3 ex_vertexposition;
varying vec3 ex_motion;
varying vec3 ex_eyevec;
varying vec3 VertexCameraPosition;
varying float selectionstate;

void main(void)
{
	mat4 entitymatrix_=entitymatrix;
	entitymatrix_[0][3]=0.0;
	entitymatrix_[1][3]=0.0;
	entitymatrix_[2][3]=0.0;
	entitymatrix_[3][3]=1.0;
	
	gl_Position = projectioncameramatrix * entitymatrix_ * vec4(vertex_position, 1.0);
    VertexCameraPosition = vec3(camerainversematrix * entitymatrix_ * vec4(vertex_position, 1.0));
	
	mat3 nmat = mat3(camerainversematrix[0].xyz,camerainversematrix[1].xyz,camerainversematrix[2].xyz);
	nmat = nmat * mat3(entitymatrix[0].xyz,entitymatrix[1].xyz,entitymatrix[2].xyz);
	
	ex_normal = (nmat * vertex_normal);
	ex_tangent = normalize(nmat * vertex_tangent);
	ex_binormal = normalize(nmat * vertex_binormal);
	
	ex_color = vec4(entitymatrix[0][3],entitymatrix[1][3],entitymatrix[2][3],entitymatrix[3][3]);
	selectionstate = 0.0;
	if (ex_color.a<-5.0)
	{
		ex_color.a += 10.0;
		selectionstate = 1.0;
	}
	ex_color *= materialcolordiffuse * (vec4(1,1,1,0) - vertex_color);
	
	ex_texcoords0 = vertex_texcoords0;
	
	ex_vertexposition = vec3(entitymatrix_ * vec4(vertex_position, 1.0));
	
	//Parallax
	//ex_eyevec.x = dot(gl_Position.xyz, ex_tangent);
	//ex_eyevec.y = dot(gl_Position.xyz, ex_binormal);
	//ex_eyevec.z = dot(gl_Position.xyz, ex_normal);
	//ex_eyevec = normalize(ex_eyevec);
	
	mat3 tbnmat;
	tbnmat[0] = ex_tangent;
	tbnmat[1] = ex_binormal;
	tbnmat[2] = ex_normal;
	ex_eyevec = -vec3(cameramatrix*vec4(ex_vertexposition.xyz,1)) * tbnmat;
	
#ifdef __GLSL_CG_DATA_TYPES
	gl_ClipVertex = entitymatrix_ * vec4(vertex_position, 1.0);
#endif
}




@OpenGL2.Fragment
#define diffusemap texture0
#define normalmap texture1
#define specularmap texture2
#define cubemap texture4

//Uniforms
uniform sampler2D texture0; //diffuse
uniform sampler2D texture1; //normal
uniform sampler2D texture2; //specular
uniform sampler2D texture3; //height
uniform samplerCube texture4; //environment
uniform sampler2D texture5; //emission
uniform sampler2D texture6; //opacity
uniform sampler2D texture7; //ambient
uniform samplerCube texture8; //refraction
uniform mat4 cameramatrix;
uniform mat4 camerainversematrix;
uniform vec4 lighting_ambient;
uniform float materialid;
uniform vec4 Color;//=vec4(1,1,1,1);//expose color
uniform float Bumpiness;//=1.0;//expose slider,0,0.9
uniform float Shininess;//=1.0;//expose slider,0,4
uniform float Gloss;//=0.5;//expose slider,0.1,1
uniform float Flip_Normals_X;//=0.0;//expose checkbox
uniform float Flip_Normals_Y;//=0.0;//expose checkbox
uniform float Offset;//=1.0;//expose slider,0,2
uniform float Invert_Height;//=0.0;//expose checkbox
uniform float Chromatic_Aberration;//=1.0;//expose slider,0,5
uniform vec3 cameraposition;
uniform mat3 camerainversenormalmatrix;
uniform vec2 buffersize;
uniform float camerazoom;
uniform vec2 camerarange;
uniform vec4 materialcolordiffuse;
uniform vec4 materialcolorspecular;

//Lighting
#ifdef LIGHTING

uniform vec3 lightdirection[4];
uniform vec4 lightcolor[4];
uniform vec4 lightposition[4];
uniform float lightrange[4];
uniform vec3 lightingcenter[4];
uniform vec2 lightingconeanglescos[4];
uniform vec4 lightspecular[4];
	
#endif

uniform float texturestrength0;// = 1.0;
uniform float texturestrength1;// = 1.0;
uniform float texturestrength2;// = 1.0;
uniform float texturestrength3;// = 0.1;
uniform float texturestrength4;// = 1.0;
uniform float texturestrength5;// = 1.0;
uniform float texturestrength6;// = 1.0;
uniform float texturestrength7;// = 1.0;
uniform float texturestrength8;// = 1.0;
uniform float texturestrength9;// = 1.0;
uniform float texturestrength10;// = 1.0;
uniform float texturestrength11;// = 1.0;
uniform float texturestrength12;// = 1.0;
uniform float texturestrength13;// = 1.0;
uniform float texturestrength14;// = 1.0;
uniform float texturestrength15;// = 1.0;

//Inputs
varying vec2 ex_texcoords0;
varying vec3 ex_normal;
varying vec3 ex_tangent;
varying vec3 ex_binormal;
varying vec4 ex_color;
varying vec3 ex_vertexposition;
varying vec3 ex_motion;
varying vec3 ex_eyevec;
varying vec3 VertexCameraPosition;
varying float selectionstate;

/*
Based on the code found here:
http://www.gamedev.net/topic/566818-what-is-needed-for-parallax-mapping/page__view__findpost__p__4626951
*/
vec2 ParallaxMap(vec2 texcoords, float scale)
{
	float fDepth = 0.0;    
	vec2 vHalfOffset = vec2(0.0,0.0);    
	int i = 0;
	float height;
	for (i=0; i<12; i++)
	{
		height = texture2D(texture3,texcoords+vHalfOffset).x * texturestrength3;
		height = Invert_Height * (1.0-height) + (1.0-Invert_Height)*height;
		fDepth = (fDepth+(1.0-height))*0.5;
		vHalfOffset = -ex_eyevec.xy*fDepth*scale / 12.0;
	}
	return vHalfOffset;
}

vec2 POM(in vec2 texcoords, in float scale)
{
	// from Microsoft's and Ati's implementation thank them for the source :)
	// Compute the ray direction for intersecting the height field profile with 
	// current view ray. See the above paper for derivation of this computation. (Ati's comment)
	
	//More samples will yield better results
	float nMinSamples = 20.0;
	float nMaxSamples = 50.0;
	
	// Compute initial parallax displacement direction: (Ati's comment)
	vec2 vparallaxdirection = normalize(ex_eyevec).xy;
	
	// The length of this vector determines the furthest amount of displacement: (Ati's comment)
    float flength = length( ex_eyevec );
	float fparallaxlength = sqrt( flength  * flength  - ex_eyevec.z * ex_eyevec.z ) / ex_eyevec.z; 
	
	// Compute the actual reverse parallax displacement vector: (Ati's comment)
	vec2 vParallaxOffsetTS = vparallaxdirection * fparallaxlength;
	
	// Need to scale the amount of displacement to account for different height ranges
	// in height maps. This is controlled by an artist-editable parameter: (Ati's comment)
	vParallaxOffsetTS *= scale; 
	
	int nNumSamples;
	nNumSamples = int((mix( nMinSamples, nMaxSamples, 1.0-dot( vparallaxdirection, ex_normal.xy ) )));	//In reference shader: int nNumSamples = (int)(lerp( nMinSamples, nMaxSamples, dot( eyeDirWS, N ) ));
    float fStepSize = 1.0/float(nNumSamples);	
	float fCurrHeight = 0.0;
	float fPrevHeight = 1.0;
	float fNextHeight = 0.0;
	int nStepIndex = 0;
	vec2 vTexOffsetPerStep = fStepSize * vParallaxOffsetTS;
	vec2 vTexCurrentOffset = texcoords.xy;
	float fCurrentBound = 1.0;
	float fParallaxAmount = 0.0;
	vec2 pt1 = vec2(0,0);
	vec2 pt2 = vec2(0,0);	    
	
	while ( nStepIndex < nNumSamples ) 
	{
		vTexCurrentOffset -= vTexOffsetPerStep;
		
		// Sample height map which in this case is stored in the alpha channel of the normal map: (Ati's comment)
		fCurrHeight = texture2D( texture3, vTexCurrentOffset).x; 
		
		fCurrentBound -= fStepSize;
		
		if ( fCurrHeight > fCurrentBound ) 
		{   
			pt1 = vec2( fCurrentBound, fCurrHeight );
			pt2 = vec2( fCurrentBound + fStepSize, fPrevHeight );
			nStepIndex = nNumSamples + 1;	//Exit loop
			fPrevHeight = fCurrHeight;
		}
		else
		{
			nStepIndex++;
			fPrevHeight = fCurrHeight;
		}
	} 
	float fDelta2 = pt2.x - pt2.y;
	float fDelta1 = pt1.x - pt1.y;
	
	float fDenominator = fDelta2 - fDelta1;
	
	// SM 3.0 requires a check for divide by zero, since that operation will generate
	// an 'Inf' number instead of 0, as previous models (conveniently) did: (Ati's comment)
	if ( fDenominator == 0.0 )
	{
		fParallaxAmount = 0.0;
	}
	else
	{
		fParallaxAmount = (pt1.x * fDelta2 - pt2.x * fDelta1 ) / fDenominator;
	}
	vec2 vParallaxOffset = vParallaxOffsetTS * (1.0 - fParallaxAmount );
	
	return -vParallaxOffset; 
}

//
// fresnel approximation
// F(a) = F(0) + (1- cos(a))^5 * (1- F(0))
//
// Calculate fresnel term. You can approximate it with 1.0-dot(normal, viewpos).	
//
float fast_fresnel(vec3 I, vec3 N, vec3 fresnelValues)
{
	float bias = fresnelValues.x;
	float power = fresnelValues.y;
	float scale = 1.0 - bias;
	return bias + pow(1.0 - dot(I, N), power) * scale;
}

float DepthToZPosition(in float depth) {
	return camerarange.x / (camerarange.y - depth * (camerarange.y - camerarange.x)) * camerarange.y;
}

void main(void)
{
	float specular;
	vec2 texcoords0;
	vec3 n;
	int i;
	float ambient;
	vec4 reflection;
	float opacity;
	vec4 refraction;
    	vec4 out_diffuse;
    	vec4 lighting_diffuse;
    	vec3 screencoord;
	vec4 color_specular = materialcolorspecular;	

    //Calculate screen coordinate
	screencoord = vec3(((gl_FragCoord.x/buffersize.x)-0.5) * 2.0 * (buffersize.x/buffersize.y),((-gl_FragCoord.y/buffersize.y)+0.5) * 2.0,DepthToZPosition( gl_FragCoord.z ));
	screencoord.x *= screencoord.z / camerazoom;
	screencoord.y *= -screencoord.z / camerazoom;    
    
	out_diffuse = ex_color;
	
	//Displacement
#ifdef TEXTURE_DISPLACEMENT
	texcoords0 = ex_texcoords0 + ParallaxMap(ex_texcoords0,Offset*0.25);
	//texcoords0 = ex_texcoords0 + POM(ex_texcoords0,Offset*0.1);
#else
	texcoords0 = ex_texcoords0;
#endif
	
	//Diffuse
#ifdef TEXTURE_DIFFUSE
      out_diffuse *= texture2D(diffusemap,texcoords0);
#endif
	
	//Specular
#ifdef TEXTURE_SPECULAR
	color_specular *= texture2D(specularmap,texcoords0);
#endif

	//Opacity
#ifdef TEXTURE_OPACITY
		opacity = texture2D(texture6,texcoords0).r * ex_color.a * Color.a * out_diffuse.a;
		opacity = out_diffuse.a * (1.0-texturestrength6) + opacity * texturestrength6;
#else
		opacity = out_diffuse.a;
#endif
	
	//Normal
#ifdef TEXTURE_NORMAL
		//n = ex_normal;
		//vec4 nv4 = texture2D(normalmap,texcoords0) * 2.0 - 1.0;
		//n.x = nv4.x;
		//n.y = nv4.y;
		//n.z = nv4.w;
		n = texture2D(normalmap,texcoords0).wyz * 2.0 - 1.0;
		//n.x *= 1.0*(1.0-Flip_Normals_X)-Flip_Normals_X;
		//n.y *= 1.0*(1.0-Flip_Normals_Y)-Flip_Normals_Y;
		//float yz = 1.0 - n.y*n.y - n.z*n.z;
		
		//Check for zero or black spots will appear
		/*if (yz>0.0)
		{
			n.x = sqrt(abs(yz));//Reconstruct the z component from the x and y components
		}
		else
		{
			n.x = 0.0;
		}*/
		//n = normalize(n);
		ambient = n.z;
		n = ex_tangent*n.x + ex_binormal*n.y + ex_normal*n.z;		
#else
		n = ex_normal;
		ambient = 1.0;
#endif
    
	//Ambient
#ifdef TEXTURE_AMBIENT
	ambient = texture2D(texture7,texcoords0).x;
	ambient = (1.0-texturestrength7) + ambient * texturestrength7;
#endif
	
	vec3 incident = normalize(ex_vertexposition-cameraposition);
	vec3 worldnormal = n * camerainversenormalmatrix;
	
	//Reflection
#ifdef TEXTURE_REFLECTION	
	reflection = texturestrength4 * textureCube(texture4,reflect( normalize(ex_vertexposition - cameraposition ), n * camerainversenormalmatrix ));
	//reflection = textureCube(texture4,reflect( normalize( vertexcameraposition.xyz*vec3(1,-1,-1) ), n));
	//reflection = reflection * (1.0 - opacity) * texturestrength4;
        //reflection = vec4(1,0,0,1);
        //gl_FragData[0] = reflection;
#else
	reflection = vec4(0);
#endif
	
	//Refraction
#ifdef TEXTURE_REFRACTION
	vec3 IoR_Values = vec3(1.14,1.12,1.10);
	IoR_Values.x = IoR_Values.y + 0.02 * Chromatic_Aberration;
	IoR_Values.z = IoR_Values.y - 0.02 * Chromatic_Aberration;
	//	refraction.r = textureCube(texture8,refract(normalize(ex_vertexposition-cameraposition),n*camerainversenormalmatrix,IoR_Values.x)).r;
	//	refraction.g = textureCube(texture8,refract(normalize(ex_vertexposition-cameraposition),n*camerainversenormalmatrix,IoR_Values.y)).g;
	//	refraction.b = textureCube(texture8,refract(normalize(ex_vertexposition-cameraposition),n*camerainversenormalmatrix,IoR_Values.z)).b;
        //refraction = textureCube(texture8,refract(normalize(ex_vertexposition-cameraposition),n*camerainversenormalmatrix,IoR_Values.x)).r;
        //refraction = refraction * (1.0 - opacity) * texturestrength8;
		
		//Mix refraction and reflection
		//#ifdef TEXTURE_REFLECTION
		//	vec3 fresnelValues = vec3(0.15,2.0,0.0);
		//	float fresnelterm = fast_fresnel(-incident, worldnormal, fresnelValues);
		//	refraction = vec4(mix(refraction, reflection, fresnelterm));
		//	reflection = vec4(0);
		//#endif
#else
	refraction = vec4(0);
#endif

#ifdef LIGHTING
	
	//Calculate lighting
	lighting_diffuse = vec4(0);
	vec4 lighting_specular = vec4(0);
	float attenuation=1.0;
	vec3 lightdir;
	vec3 lightreflection;
	
	//One equation, three light types
	for (i=0; i<4; i++)
	{
		lightdir = normalize(VertexCameraPosition - lightposition[i].xyz) * lightposition[i].w + lightdirection[i] * (1.0 - lightposition[i].w);        
		attenuation = lightposition[i].w * max(0.0, 1.0 - distance(lightposition[i].xyz,VertexCameraPosition) / lightrange[i]) + (1.0 - lightposition[i].w);        
		attenuation *= max(0.0,dot(n,-lightdir));
        float anglecos = max(0.0,dot(lightdirection[i],lightdir));
        attenuation *= 1.0 - clamp((lightingconeanglescos[i].y-anglecos)/(lightingconeanglescos[i].y-lightingconeanglescos[i].x),0.0,1.0);
		lighting_diffuse += lightcolor[i] * attenuation;
		lightreflection = normalize(reflect(lightdir,n));
       	lighting_specular += pow(clamp(-dot(lightreflection,normalize(screencoord)),0.0,1.0),20.0) * attenuation * lightspecular[i]; 
	}
	//gl_FragColor=lighting_diffuse;
	lighting_specular *= color_specular;
	out_diffuse += reflection;
	gl_FragColor = (lighting_diffuse + lighting_ambient * ambient) * out_diffuse + lighting_specular + reflection;	
#else
	#ifdef SIMPLESHADING
	vec4 lightdir = vec4(-0.4,-0.7,0.5,1.0);
	lightdir = lightdir * cameramatrix;
	float intensity = -dot(n,lightdir.xyz);
	out_diffuse *= 0.75 + intensity * 0.25;
	gl_FragColor = out_diffuse;
	#else
	gl_FragColor = out_diffuse;
	#endif
#endif
	
	gl_FragColor.a = 1.0;
	
	//Selection mask
	if (selectionstate>0.0)
	{
		gl_FragColor = vec4(0.5,0,0,0) + gl_FragColor * 0.5;
	}
	//gl_FragColor.r=1.0;	
}

