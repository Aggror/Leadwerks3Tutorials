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
	
	//Hide the mouse cursor
	window->HideMouse();
	
	std::string mapname = System::GetProperty("map","Maps/start.map");
	Map::Load(mapname);
	
	//Move the mouse to the center of the screen
	window->SetMousePosition(context->GetWidth()/2,context->GetHeight()/2);
	
	return true;
}

bool App::Loop()
{
	//Close the window to end the program
	if (window->Closed()) return false;
    
	//Press escape to end freelook mode
	if (window->KeyHit(Key::Escape))
	{
		if (!freelookmode) return false;
		freelookmode=false;
		window->ShowMouse();
	}
	
	if (freelookmode)
	{
		//Keyboard movement
		float strafe = (window->KeyDown(Key::D) - window->KeyDown(Key::A))*Time::GetSpeed() * 0.05;
		float move = (window->KeyDown(Key::W) - window->KeyDown(Key::S))*Time::GetSpeed() * 0.05;
		camera->Move(strafe,0,move);

		//Get the mouse movement
		float sx = context->GetWidth()/2;
		float sy = context->GetHeight()/2;
		Vec3 mouseposition = window->GetMousePosition();
		float dx = mouseposition.x - sx;
		float dy = mouseposition.y - sy;

		//Adjust and set the camera rotation
		camerarotation.x += dy / 10.0;
		camerarotation.y += dx / 10.0;
		camera->SetRotation(camerarotation);

		//Move the mouse to the center of the screen
		window->SetMousePosition(sx,sy);
	}

	Time::Update();
	world->Update();
	world->Render();
	context->Sync(false);
	
	return true;
}
