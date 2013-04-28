#include "App.h"

using namespace Leadwerks;

App::App() : window(NULL), context(NULL), world(NULL), camera(NULL) {}

App::~App() { delete world; delete window; }

bool App::Start()
{
	//Create a window
	window = Window::Create("_11_Classes", 200, 0, 1024,768);
		
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
	
	//Create our own player
	myPlayer = Player(window, context, camera);

	return true;
}

bool App::Loop()
{
	//Close the window to end the program
	if (window->Closed()||window->KeyHit(Key::Escape)) return false;

	myPlayer.Update();
   
	Time::Update();
	world->Update();
	world->Render();

	context->Sync(true);

	
	return true;
}
