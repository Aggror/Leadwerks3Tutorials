#include <jni.h>
#include <GLES2/gl2.h>
#include <stdlib.h>
#include <android/log.h>
#include "../../../Source/App.h"
#include "Leadwerks.h"
#include "leandroid.h"

bool AppPaused = false;
bool disableRender = false;
bool AppEverStarted = false;
bool graphicsReloadNeeded = false;
bool initialOrientationSet = false;
App* app = NULL;

DeviceOrientation deviceOrientation = PORTRAIT;
	
JNIEnv *jnienv = NULL;
jobject jniobj = NULL;

void setDeviceOrientation(DeviceOrientation newOrientation)
{
	if (newOrientation == LANDSCAPE) Leadwerks::Device::orientation = Leadwerks::Device::Landscape;
	if (newOrientation == PORTRAIT) Leadwerks::Device::orientation = Leadwerks::Device::Portrait;

	deviceOrientation = newOrientation;

	jclass renderer = jnienv->GetObjectClass(jniobj);

	if(!renderer) {
		Leadwerks::Print("FindClass error");
		return;
	}

	jmethodID javamethod = jnienv->GetMethodID(renderer, "setDeviceOrientation", "(I)V");

	if(!javamethod) {
		Leadwerks::Print("FindMethod error");
		return;
	}

	jnienv->CallVoidMethod(jniobj, javamethod, (int)deviceOrientation);
}

extern "C" {
	
	std::string ConvertJString(JNIEnv* env, jstring str)
	{
	   if ( !str ) return "";

	   const jsize len = env->GetStringUTFLength(str);
	   const char* strChars = env->GetStringUTFChars(str, (jboolean *)0);

	   std::string Result(strChars, len);

	   env->ReleaseStringUTFChars(str, strChars);

	   return Result;
	}
	
	JNIEXPORT void JNICALL Java_com_leadwerks_leandroidb_AndroidSurfaceView_setAPKFilePath(JNIEnv * env, jobject obj, jstring path)
	{
//#define USEEXTERNALMEMORY
#ifdef USEEXTERNALMEMORY
		//Leadwerks::Print("Leadwerks::FileSystem::SetDir(\"/Leadwerks\");");
		//Leadwerks::Print(Leadwerks::FileSystem::FixPath("/Leadwerks"));
		Leadwerks::FileSystem::SetDir("sdcard/Leadwerks/");
		//Leadwerks::Print(Leadwerks::FileSystem::GetDir());
#else
		std::string s = ConvertJString(env,path);
		std::string appdir = Leadwerks::FileSystem::ExtractDir(s);
		std::string packagedir = Leadwerks::FileSystem::StripExt(s);

		//Leadwerks::Print("APK file: \""+s+"\"");

		//Load the APK file as a file package
		Leadwerks::Package* package = Leadwerks::Package::Load(s);
		//Leadwerks::RegisterPackage(package);

		//Set the directory to the /res/raw folder inside the file package
		Leadwerks::FileSystem::SetDir(appdir);
		//Leadwerks::Print("Package: "+s);
		//Leadwerks::Print("AppDir: "+appdir);

		/*Leadwerks::Directory* dir = Leadwerks::FileSystem::LoadDir(appdir);
		for (int i=0; i<dir->CountFiles(); i++)
		{
			std::string file = dir->GetFile(i);
			Leadwerks::Print(file);
		}
		delete dir;*/

		//Load filesystem virtual mapping
		Leadwerks::Stream* stream = Leadwerks::FileSystem::ReadFile(packagedir+"/res/raw/filesystem.txt");
		if (stream!=NULL)
		{
			std::vector<std::string> sarr;
			while (stream->EOF()==false)
			{
				s = stream->ReadLine();
				sarr = Leadwerks::String::Split(s,":");
				if (sarr.size()==2)
				{
					//Insert virtual file mapping into map
					Leadwerks::FileSystem::VirtualFileSystem[Leadwerks::FileSystem::GetDir()+"/"+sarr[0]]=packagedir+"/res/raw/"+sarr[1];
					//Leadwerks::Print(Leadwerks::FileSystem::GetDir()+"/"+sarr[0]);
					//Leadwerks::Print(packagedir+"/res/raw/"+sarr[1]);
				}
			}
			stream->Release();
		}
#endif
	}

	void ReloadGraphics()
	{
		bool waspaused = Leadwerks::timepausestate;
		Leadwerks::Time::Pause();

		//Leadwerks::Print("RELOADING GRAPHICS");
		
		std::list<Leadwerks::Asset*>::iterator asset;
		std::list<Leadwerks::Surface*>::iterator surface;
		std::string classname;
		Leadwerks::OpenGLES2VertexArray* vertexarray;
		Leadwerks::OpenGLES2IndiceArray* indicearray;
		Leadwerks::OpenGLES2Shader* opengles2shader;
		Leadwerks::Shader* shader;

		//Reload assets
		for ( asset = Leadwerks::Asset::List.begin() ; asset != Leadwerks::Asset::List.end(); asset++ )
		{
			classname = (*asset)->GetClassName();
		
			//Textures
			if (classname == "Texture")
			{
				((Leadwerks::OpenGLES2Texture*)*asset)->gltexturehandle = 0;
				if ((*asset)->path!="")
				{
					//Leadwerks::Print("Reloading texture "+(*asset)->path);
					(*asset)->Reload();
				}
			}
		
			//Shaders
			if (classname == "Shader")
			{
				//Leadwerks::Print("Recompiling shader "+(*asset)->path);
				opengles2shader = ((Leadwerks::OpenGLES2Shader*)*asset);
				opengles2shader->program = 0;
				opengles2shader->object[Leadwerks::Shader::Vertex] = 0;
				opengles2shader->object[Leadwerks::Shader::Pixel] = 0;
				if (opengles2shader->Compile(Leadwerks::Shader::Vertex))
				{
					if (opengles2shader->Compile(Leadwerks::Shader::Pixel))
					{
						opengles2shader->Link();
					}
				}
			}
		}
		
		//Reload assets - second pass
		for ( asset = Leadwerks::Asset::List.begin() ; asset != Leadwerks::Asset::List.end(); asset++ )
		{
			classname = (*asset)->GetClassName();
			
			//Fonts
			if (classname == "Font")
			{
				//Leadwerks::Print("Reloading font "+(*asset)->path);
				(*asset)->Reload();
			}
		}
		
		//Dump VBOs and recreate them
		for ( surface = Leadwerks::Surface_list.begin() ; surface != Leadwerks::Surface_list.end(); surface++ )
		{
			vertexarray = (Leadwerks::OpenGLES2VertexArray*)((Leadwerks::OpenGLES2Surface*)*surface)->positionarray;
			if (vertexarray) vertexarray->buffer = 0;
			vertexarray = (Leadwerks::OpenGLES2VertexArray*)((Leadwerks::OpenGLES2Surface*)*surface)->normalarray;
			if (vertexarray) vertexarray->buffer = 0;
			vertexarray = (Leadwerks::OpenGLES2VertexArray*)((Leadwerks::OpenGLES2Surface*)*surface)->animatedpositionarray;
			if (vertexarray) vertexarray->buffer = 0;
			vertexarray = (Leadwerks::OpenGLES2VertexArray*)((Leadwerks::OpenGLES2Surface*)*surface)->animatednormalarray;
			if (vertexarray) vertexarray->buffer = 0;
			vertexarray = (Leadwerks::OpenGLES2VertexArray*)((Leadwerks::OpenGLES2Surface*)*surface)->colorarray;
			if (vertexarray) vertexarray->buffer = 0;
			vertexarray = (Leadwerks::OpenGLES2VertexArray*)((Leadwerks::OpenGLES2Surface*)*surface)->binormalarray;
			if (vertexarray) vertexarray->buffer = 0;
			vertexarray = (Leadwerks::OpenGLES2VertexArray*)((Leadwerks::OpenGLES2Surface*)*surface)->tangentarray;
			if (vertexarray) vertexarray->buffer = 0;			
			vertexarray = (Leadwerks::OpenGLES2VertexArray*)((Leadwerks::OpenGLES2Surface*)*surface)->texcoordsarray[0];
			if (vertexarray) vertexarray->buffer = 0;			
			vertexarray = (Leadwerks::OpenGLES2VertexArray*)((Leadwerks::OpenGLES2Surface*)*surface)->texcoordsarray[1];
			if (vertexarray) vertexarray->buffer = 0;
			indicearray = (Leadwerks::OpenGLES2IndiceArray*)((Leadwerks::OpenGLES2Surface*)*surface)->indicearray;
			if (indicearray) indicearray->buffer = 0;
			(*surface)->Lock();
		}
		
		shader = Leadwerks::Shader::GetCurrent();
		if (shader) shader->Enable();

		if (!waspaused) Leadwerks::Time::Resume();
	}
	
	JNIEXPORT void JNICALL Java_com_leadwerks_leandroidb_AndroidRenderer_init(JNIEnv * env, jobject obj,  jint width, jint height)
	{
		//Leadwerks::Print("Initializing");
		//Leadwerks::Print(Leadwerks::FileSystem::GetDir());

		jnienv = env;
		jniobj = obj;
		
		//Doing pretty much anything, including setting the device orientation in this function can cause "Failed to Set Top App" error.
		Leadwerks::AndroidWindowWidth = width;
		Leadwerks::AndroidWindowHeight = height;
		if (!AppEverStarted)
		{
			//setDeviceOrientation(PORTRAIT);
			if (Leadwerks::Device::GetOrientation()==Leadwerks::Device::Landscape)
			{
			//	setDeviceOrientation(LANDSCAPE);
			}
			else
			{
			//	setDeviceOrientation(PORTRAIT);
			}
			//AppEverStarted = true;
			//Leadwerks::Print("START");
			//App::Start();
		}
		else
		{
			//Leadwerks::Print("APPLICATION TRYING TO CALL START BUT ALREADY STARTED");
			//disableRender = false;
			//graphicsReloadNeeded = true;
			//ReloadGraphics();
		}
	}

	JNIEXPORT void JNICALL Java_com_leadwerks_leandroidb_AndroidRenderer_step(JNIEnv * env, jobject obj)
	{
		//==========================================================================================
		//Comment out this code block if you want portrait orientation to be the default
		//==========================================================================================
		if (!initialOrientationSet)
		{
			initialOrientationSet = true;
			Leadwerks::Device::orientation = Leadwerks::Device::Landscape;
			setDeviceOrientation(LANDSCAPE);
			graphicsReloadNeeded = false;
			return;
		}
		//==========================================================================================
		//
		//==========================================================================================

		if (!disableRender)//This is set to true when the screen is rotated.  It is set back to false when a new context is created.
		{
			if (!AppPaused)
			{
				if (!AppEverStarted)
				{
					Leadwerks::Device::orientation = Leadwerks::Device::Landscape;
					//Leadwerks::Print("App::Start");
					graphicsReloadNeeded = false;
					app = new App;
					OpenGLES2GraphicsDriver::backframebufferobject = glGetInteger(GL_FRAMEBUFFER_BINDING);
					if (!app->Start())
					{
						delete app;
						app=NULL;
					}
					AppEverStarted = true;
				}

				//If device orientation has changed, update it here.
				if (Leadwerks::Device::orientation==Leadwerks::Device::Landscape)
				{
					setDeviceOrientation(LANDSCAPE);
				}
				else if (Leadwerks::Device::orientation==Leadwerks::Device::Portrait)
				{
					setDeviceOrientation(PORTRAIT);
				}
				if (graphicsReloadNeeded)
				{
					graphicsReloadNeeded = false;
					ReloadGraphics();
				}
				if (app)
				{
					OpenGLES2GraphicsDriver::backframebufferobject = glGetInteger(GL_FRAMEBUFFER_BINDING);
					if (!app->Loop())
					{
						delete app;
						app = NULL;
					}
				}
			}
		}
	}
	
	JNIEXPORT void JNICALL Java_com_leadwerks_leandroidb_AndroidRenderer_up(JNIEnv * env, jobject obj, jfloat x, jfloat y, jint touchId)
	{
		//Leadwerks::Print("Up! "+Leadwerks::String(x)+", "+Leadwerks::String(y));
		/*Leadwerks::AndroidCursorX = x;
		Leadwerks::AndroidCursorY = y;
		Leadwerks::AndroidCursorDown = false;*/
		if(touchId < 0) return;
		Leadwerks::_TouchDownState[touchId] = false;
		Leadwerks::Event(Leadwerks::Event::TouchUp, NULL, touchId, x, y).Emit();
		//Leadwerks::Print("Touch up "+Leadwerks::String(touchId));
	}
	
	JNIEXPORT void JNICALL Java_com_leadwerks_leandroidb_AndroidRenderer_move(JNIEnv * env, jobject obj, jfloat x, jfloat y, jint touchId)
	{
		//Leadwerks::Print("Move! "+Leadwerks::String(x)+", "+Leadwerks::String(y));
		/*Leadwerks::AndroidCursorX = x;
		Leadwerks::AndroidCursorY = y;
		Leadwerks::AndroidCursorDown = true;*/
		if(touchId < 0) return;
		Leadwerks::_TouchPosition[touchId].x = x;
		Leadwerks::_TouchPosition[touchId].y = y;
		Leadwerks::Event(Leadwerks::Event::TouchDown,NULL,touchId,x,y).Emit();
		//Leadwerks::Print("Touch move "+Leadwerks::String(touchId));
	}
	
	JNIEXPORT void JNICALL Java_com_leadwerks_leandroidb_AndroidRenderer_touch(JNIEnv * env, jobject obj, jfloat x, jfloat y, jint touchId)
	{
		//Leadwerks::Print("Touch down "+Leadwerks::String(touchId));
		Leadwerks::AndroidCursorX = x;
		Leadwerks::AndroidCursorY = y;
		Leadwerks::AndroidCursorHit = true;
		Leadwerks::AndroidCursorDown = true;
		if(touchId < 0) return;
		Leadwerks::_TouchPosition[touchId].x = x;
		Leadwerks::_TouchPosition[touchId].y = y;
		Leadwerks::_TouchHitState[touchId]=true;
		Leadwerks::_TouchDownState[touchId]=true;
		//Leadwerks::Event(Leadwerks::Event::TouchMove,NULL,touchId,x,y).Emit();
	}
	
	JNIEXPORT void JNICALL Java_com_leadwerks_leandroidb_AndroidRenderer_recreateSurface(JNIEnv * env, jobject obj,  jint width, jint height)
	{
		//Leadwerks::Print(Leadwerks::String(width)+" x "+Leadwerks::String(height));
		//Leadwerks::Print("RECREATESURFACE");
		disableRender = false;
		Leadwerks::AndroidWindowWidth = width;
		Leadwerks::AndroidWindowHeight = height;
		//ReloadGraphics();
		graphicsReloadNeeded = true;
	}
	
	bool AppWasAlreadyPaused = false;
	
	JNIEXPORT void JNICALL Java_com_leadwerks_leandroidb_AndroidRenderer_pause(JNIEnv * env, jobject obj)
	{
		Leadwerks::SoundDriver* sounddriver = Leadwerks::SoundDriver::GetCurrent();
		if (sounddriver) sounddriver->Suspend();
		AppPaused = true;
		AppWasAlreadyPaused = Leadwerks::timepausestate;
		//Leadwerks::Print("PAUSE");
		Leadwerks::Time::Pause();
	}
	
	JNIEXPORT void JNICALL Java_com_leadwerks_leandroidb_AndroidRenderer_resume(JNIEnv * env, jobject obj)
	{
		if (AppEverStarted)
		{
			Leadwerks::SoundDriver* sounddriver = Leadwerks::SoundDriver::GetCurrent();
			if (sounddriver) sounddriver->Resume();
			AppPaused = false;
			if (!AppWasAlreadyPaused) Leadwerks::Time::Resume();
			//Leadwerks::Print("RESUME");
		}
	}
	
	JNIEXPORT void JNICALL Java_com_leadwerks_leandroidb_AndroidRenderer_handleRotate(JNIEnv * env, jobject obj)
	{
		//Disable rendering until a new context is created
		disableRender = true;
	
		//Leadwerks::Print("--------------------------------");
		//Leadwerks::Print("Screen Rotated.");
		//Leadwerks::Print("--------------------------------");	
	}

	JNIEXPORT int JNICALL Java_com_leadwerks_leandroidb_AndroidRenderer_getDeviceOrientation(JNIEnv * env, jobject obj)
	{
		//Leadwerks::Print("--------------------------------");
		//Leadwerks::Print("getDeviceOrientation");
		//Leadwerks::Print("--------------------------------");
		return deviceOrientation;
	}
	
	JNIEXPORT int JNICALL Java_com_leadwerks_leandroidb_AndroidRenderer_onSensorChanged(JNIEnv * env, jobject obj, jfloat x, jfloat y, jfloat z)
	{
		//Leadwerks::Print("onSensorChanged");
		Leadwerks::Device::acceleration.x = x;
		Leadwerks::Device::acceleration.y = y;
		Leadwerks::Device::acceleration.z = z;
	}
};
