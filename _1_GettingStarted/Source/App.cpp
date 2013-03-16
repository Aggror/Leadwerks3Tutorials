#include "App.h"

using namespace Leadwerks;

App::App() : window(NULL), context(NULL), world(NULL), camera(NULL) {}

App::~App() { delete world; delete window; }

bool App::Start()
{
	//Create a window
	window = Window::Create("_1_GettingStarted", 50,50,800,600, Leadwerks::Window::Titlebar);
	
	//Create a context
	context = Context::Create(window);
	
	//Create a world
	world = World::Create();

	move = Vec2(0,250);
	
	return true;
}

bool App::Loop()
{
	

	//Close the window to end the program
	if (window->Closed()) return false;
    
	move.x += 1 * Time::GetSpeed();


	////////////////////////////////
	Time::Update();
	world->Update();
	world->Render();
	/////////////////////////////////////

	context->Clear();
	context->SetColor(120,120,0);
	context->DrawRect(0, 0, 100, 60);
	context->SetBlendMode(Blend::Alpha);
	context->SetColor(255,0,0);
	context->DrawText("Hello world!",move.x,move.y );
	context->SetBlendMode(Blend::Solid);
	context->SetColor(0,0,0);
	

	context->Sync();
	
	return true;
}
