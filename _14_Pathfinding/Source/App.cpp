#include "App.h"
#include "../Projects/Windows/Person.h"
#include "../Projects/Windows/Beggar.h"

using namespace Leadwerks;

App::App() : window(NULL), context(NULL), world(NULL), camera(NULL) {}

App::~App() { delete world; delete window; }

Vec3 camerarotation;

//Store all the npc
Person* player;
Beggar* beggar;

Model* pickSphere;

bool App::Start()
{
	//Create a window
	window = Window::Create("_14_Pathfinding");
	
	//Create a context
	context = Context::Create(window);
	
	//Create a world
	world = World::Create();
	
	//Create a camera
	camera = Camera::Create();
	camera->Move(0,2,-5);
	
	//Hide the mouse cursor
	window->HideMouse();
	
	Map::Load("Maps/start.map");
	
	//Move the mouse to the center of the screen
	window->SetMousePosition(context->GetWidth()/2,context->GetHeight()/2);

	//Player
	player = new Person(Vec3(-1,5,0), 5, 3);
	
	//Beggar
	beggar = new Beggar(player, Vec3(13,5,-1), 4, 2, 2, 15);
	
	//picksphere
	pickSphere = Model::Sphere(12);
	pickSphere->SetScale(0.5);
	
	return true;
}

bool App::Loop()
{
	//Close the window to end the program
	if (window->Closed() || window->KeyHit(Key::Escape)) return false;
    
	if(window->KeyHit(Key::P))
		camera->drawphysicsmode = !camera->drawphysicsmode;

	//Keyboard movement
	float strafe = (window->KeyDown(Key::D) - window->KeyDown(Key::A))*Time::GetSpeed() * 0.1;
	float move = (window->KeyDown(Key::W) - window->KeyDown(Key::S))*Time::GetSpeed() * 0.1;
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
	
	//Place a new target position for our npcewa
	if (window->MouseHit(1))
    {
            PickInfo pickinfo;
            Vec3 p = window->GetMousePosition();
            if (camera->Pick(p.x,p.y,pickinfo,0,true))
            {
                    pickSphere->SetPosition(pickinfo.position);
					player->SetTarget(pickinfo.position);
            }
    }
	
	//Only check for destination if npc is walking
	if(player->state == Person::State::WALKING)
		player->CheckDestination();

	//Allways check the beggar
	beggar->CheckPlayerDistance();
		
	Time::Update();
	world->Update();
	world->Render();
	context->Sync(false);
	
	return true;
}