#include "App.h"
#include "../Source/Libraries/rapidxml-1.13/rapidxml.hpp"
#include "../Source/Libraries/rapidxml-1.13/rapidxml_print.hpp"

using namespace Leadwerks;
using namespace rapidxml;

App::App() : window(NULL), context(NULL), world(NULL), camera(NULL) {}

App::~App() { delete world; delete window; }

Stream* myData;
Stream* myText;

list<Entity*> entities;

//Xml file
xml_document<> doc;

void StoreWorldObjects(Entity* entity, Object* extra)
{
	System::Print("Loaded an entity and stored it: " + entity->GetKeyValue("name"));
	entities.push_back(entity);
}

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

	//Loading and saving with LE3 API
	/*
	//Save some data
	myData = FileSystem::WriteFile("myData.aggror");

	//Write some data
	myData->WriteInt(2);
	//myData->WriteFloat(1.7);
	//myData->WriteString("Hello world");
	//myData->WriteString("Hello computer");
	//myData->WriteLine("Hello Word with a new line");

	//Set read/write cursor
	myData->Seek(0);

	System::Print(myData->ReadInt());
	//System::Print(myData->ReadFloat());
	//System::Print(myData->ReadString() + myData->ReadString() + myData->ReadString() );

	//Create another stream
	myText = FileSystem::ReadFile("myText.txt");
	if (myText == NULL) 
	Debug::Error("The file does not exist!");

	//Read the entire text file
	while (!myText->EOF())
	{
	//System::Print(myText->ReadLine());
	}

	//Free from memory
	myData->Release();
	myText->Release();
	*/

	//Load map
	//Map::Load("Maps/start.map");
	Map::Load("Maps/start.map", StoreWorldObjects);


	return true;
}

bool App::Loop()
{
	//Close the window to end the program
	if (window->Closed()) return false;

	if(window->KeyHit(Key::Space))
	{
		list<Entity*>::iterator iter = entities.begin();
		for( iter; iter != entities.end(); iter++)
		{
			Entity* entity = *iter;
			if(entity->GetKeyValue("name") == "Player")
			{
				entity->SetPosition(-1,1,1);
			}
		}
	}

	//Save
	if(window->KeyHit(Key::S))
	{
		//Create XML object
		xml_node<>* decl = doc.allocate_node(node_declaration);
		decl->append_attribute(doc.allocate_attribute("version", "1.0"));
		decl->append_attribute(doc.allocate_attribute("encoding", "utf-8"));
		doc.append_node(decl);

		//Createa  root of the xml
		xml_node<>* root = doc.allocate_node(node_element, "GameRoot");
		root->append_attribute(doc.allocate_attribute("version", "1.0"));
		root->append_attribute(doc.allocate_attribute("info", "The root of my level Data"));
		doc.append_node(root);

		//Store position of every entity
		list<Entity*>::iterator iter = entities.begin();
		for( iter; iter != entities.end(); iter++)
		{
			Entity* entity = *iter;
			Vec3 pos = entity->GetPosition();
			System::Print(pos.x);
			//Create an entity root and store it in the game root
			xml_node<>* entityRoot = doc.allocate_node(node_element, "Entity");
			root->append_node(entityRoot);
 

			//Create an entity root and store it in the game root
			xml_node<>* posRoot = doc.allocate_node(node_element, "Position");
		//	char* test = String((pos.x)).c_str();
			posRoot->append_attribute(doc.allocate_attribute("x", ));
			posRoot->append_attribute(doc.allocate_attribute("y", "77"));
			posRoot->append_attribute(doc.allocate_attribute("z", "123.345"));
			entityRoot->append_node(posRoot);			
		}
		// Convert doc to string if needed
		string levelDataString;
		rapidxml::print(std::back_inserter(levelDataString), doc);
		System::Print(levelDataString);

		//Save the xml to a file
		Stream* levelDataStream = FileSystem::WriteFile("levelData.xml");
		levelDataStream->WriteString(levelDataString);

		//Cleaning things up
		levelDataStream->Release();
		doc.clear();
	}



	Time::Update();
	world->Update();
	world->Render();


	context->Sync(false);

	return true;
}
