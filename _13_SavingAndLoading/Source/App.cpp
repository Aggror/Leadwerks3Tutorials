#include "App.h"

using namespace Leadwerks;

App::App() : window(NULL), context(NULL), world(NULL), camera(NULL) {}

App::~App() { delete world; delete window; }

Stream* myData;
Stream* myText;

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

	System::Print(myData->ReadInt());
	System::Print(myData->ReadFloat());
	System::Print(myData->ReadString() + myData->ReadString() + myData->ReadString() );

	//Create another stream
	myText = FileSystem::ReadFile("myText.txt");
	if (myText == NULL) 
		Debug::Error("The file does not exist!");

	//Read the entire text file
	while (!myText->EOF())
	{
		System::Print(myText->ReadLine());
	}

	//Free from memory
	myData->Release();
	myText->Release();


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
