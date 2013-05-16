#include "App.h"

using namespace Leadwerks;

App::App() : window(NULL), context(NULL), world(NULL), camera(NULL) {}

App::~App() { delete world; delete window; }

Stream* myData;

bool App::Start()
{
	//Create a window
	window = Window::Create("_13_SavingAndLoading");
	
	//Create a context
	context = Context::Create(window);
	
	//Create a world
	world = World::Create();
	
	//Create a camera
	camera = Camera::Create();
	camera->Move(0,2,-5);
	
	//Load map
	Map::Load("Maps/start.map");
	
	//Save some data
	myData = FileSystem::WriteFile("myData.aggror");

	//Write some data
	myData->WriteInt(2);
	myData->WriteFloat(1.7);
	myData->WriteString("Hello world");
	myData->WriteString("Hello computer");
	myData->WriteLine("Hello Word with a new line");

	//Set read/write cursor
	myData->Seek(0);
	return true;
}

bool App::Loop()
{
	//Close the window to end the program
	if (window->Closed()) return false;
   

	Time::Update();
	world->Update();
	world->Render();

	context->SetBlendMode(Blend::Alpha);
    context->SetColor(1,1,1);
	 
	context->DrawText("int: " + String(myData->ReadInt()) , 0, 25);
	context->DrawText("float: " + String(myData->ReadFloat()) , 0, 40);
	context->DrawText("string: " + myData->ReadLine() + myData->ReadLine() + myData->ReadLine() , 0, 55);
    context->SetBlendMode(Blend::Solid);

	context->Sync(false);
	
	return true;
}
