#include "App.h"

using namespace Leadwerks;

App::App() : window(NULL), context(NULL), world(NULL), camera(NULL) {}

App::~App() { delete world; delete window; }

Vec3 camerarotation;
#if defined (PLATFORM_WINDOWS) || defined (PLATFORM_MACOS)
bool freelookmode=true;
#else
bool freelookmode=false;
#endif

bool App::Start()
{
	//Create a window
	window = Window::Create("_1_GettingStarted");
	
	//Create a context
	context = Context::Create(window);
	
	//Create a world
	world = World::Create();
	
	//Create a camera
	camera = Camera::Create();
	camera->Move(0,2,-5);
	
	
	return true;
}

bool App::Loop()
{
	//Close the window to end the program
	if (window->Closed()) return false;
    

	Time::Update();
	world->Update();
	world->Render();


	context->Sync(false);
	
	return true;
}
