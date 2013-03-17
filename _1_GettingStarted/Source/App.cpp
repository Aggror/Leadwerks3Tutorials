#include "App.h"

using namespace Leadwerks;

App::App() : window(NULL), context(NULL), world(NULL), camera(NULL) {}

App::~App() { delete world; delete window; }

Vec2 pos;

bool App::Start()
{
	//Create a window
	window = Window::Create("_1_GettingStarted", 50,50,800,600, Leadwerks::Window::Titlebar);
	
	//Create a context
	context = Context::Create(window);
	
	//Create a world
	world = World::Create();

	// Initialse pos variable
	pos = Vec2(0,0);
	
	return true;
}

bool App::Loop()
{
	//Close the window to end the program
	if (window->Closed()) return false;
    
	pos.x += 1 * Time::GetSpeed();

	// Context->Clear();
	context->SetColor(120,120,0);
	context->DrawRect(0, 0, 100, 60);
	
	// Draw red text
	context->SetColor(255,0,0);
	context->SetBlendMode(Blend::Alpha);
	context->DrawText("Hello world!",pos.x, 500 );
	context->SetBlendMode(Blend::Solid);
	
	// Set background color to black
	context->SetColor(0,0,0);
	context->Sync();
	
	return true;
}
