#include "App.h"
#include "../Source/Libraries/pugixml-1-2/pugixml.hpp"

using namespace Leadwerks;
using namespace pugi;

App::App() : window(NULL), context(NULL), world(NULL), camera(NULL) {}

App::~App() { delete world; delete window; }

//Streams
Stream* myData;
Stream* myText;

//Store entities
vector<Entity*> entities;

//Xml file
pugi::xml_document xmlStorage;

//Store all entities when map is loaded
void StoreWorldObjects(Entity* entity, Object* extra)
{
	System::Print("Loaded an entity and stored it: " + entity->GetKeyValue("name"));
	entities.push_back(entity);
	
}

//SaveToXML
void SaveToXML()
{
	//Reset the file
	xmlStorage.reset();

	//Root node
	xml_node rootNode = xmlStorage.append_child("Game");
		
	// Entities node stores entities
	xml_node entitiesNode = rootNode.append_child("Entities");
	
	//Store position of every entity
	vector<Entity*>::iterator iter = entities.begin();
	int id = 0;
	for( iter; iter != entities.end(); iter++)
	{
		Entity* entity = *iter;
		Vec3 pos = entity->GetPosition();

		// Entities node stores entities
		xml_node entityNode = entitiesNode.append_child("Entity");

		// Store ID node
		xml_node idNode = entityNode.append_child("ID");
		idNode.append_attribute("value") = id;
		id++;
		
		// Entities node stores entities
		xml_node positionNode = entityNode.append_child("Position");
		positionNode.append_attribute("X") = pos.x;
		positionNode.append_attribute("Y") = pos.y;
		positionNode.append_attribute("Z") = pos.z;
	}

	// save document to file
	xmlStorage.save_file("save_file_output.xml");
	System::Print("Game saved!");
}


float XMLToFloat(const char * str)
{
	return atof(str);
}


//LoadFromXML
void LoadFromXML()
{
	//Load the xml file
	xmlStorage.load_file("save_file_output.xml");
	
	//Find the entities node
	xml_node entitiesNode = xmlStorage.child("Game").child("Entities");

	//Go through all entities
	int i = 0;
	for (xml_node entity = entitiesNode.first_child(); entity; entity = entity.next_sibling())
	{
		//Retrieve idNode
		xml_node idNode = entity.child("ID");
		int id = XMLToFloat(idNode.attribute("X").value());

		//Retrieve positionNode
		xml_node positionNode = entity.child("Position");
		//std::cout << "X: " << positionNode.attribute("X").value();
		//std::cout << "Y: " << positionNode.attribute("Y").value();
		//std::cout << "Z: " << positionNode.attribute("Z").value();
		entities[id]->SetPosition(XMLToFloat(positionNode.attribute("X").value()),
										XMLToFloat(positionNode.attribute("Y").value()),
										XMLToFloat(positionNode.attribute("Z").value()));
	
	}
	
	System::Print("Game loaded!");
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
	myData = FileSystem::WriteFile("myData.dat");

	//Write some data
	//myData->WriteInt(2);
	myData->WriteFloat(1.7);
	//myData->WriteString("Hello world");
	//myData->WriteString("Hello computer");
	//myData->WriteLine("Hello Word with a new line");

	//Set read/write cursor
	myData->Seek(0);

	//System::Print(myData->ReadInt());
	System::Print(myData->ReadFloat());
	//System::Print(myData->ReadString() + myData->ReadString() + myData->ReadString() );

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

	//Place the oildrum somewhere else
	if(window->KeyHit(Key::Space))
	{
		vector<Entity*>::iterator iter = entities.begin();
		for( iter; iter != entities.end(); iter++)
		{
			Entity* entity = *iter;
			if(entity->GetKeyValue("name") == "Oildrum")
			{
				entity->SetPosition( -3, Math::Random(3.0, -2.0), Math::Random(1.0, 10.0));
			}
		}
	}

	//Save
	if(window->KeyHit(Key::S))
		SaveToXML();

	//Load
	if(window->KeyHit(Key::L))
		LoadFromXML();

	Time::Update();
	world->Update();
	world->Render();


	context->Sync(false);

	return true;
}