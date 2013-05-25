#include "App.h"
#include "../Projects/Windows/NPC.h"
#include "../Projects/Windows/Beggar.h"

using namespace Leadwerks;

App::App() : window(NULL), context(NULL), world(NULL), camera(NULL) {}

App::~App() { delete world; delete window; }

Vec3 camerarotation;

//Store all the npc
NPC* npc1;
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
	
	Map::Load("Maps/pathfinding-endResult.map");
	
	//Move the mouse to the center of the screen
	window->SetMousePosition(context->GetWidth()/2,context->GetHeight()/2);

	//NPC's
	npc1 = new NPC(Vec3(-1,5,0), 5, 3);
	
	//Beggar
	beggar = new Beggar(npc1, Vec3(13,5,-1), 4, 2, 2, 15);
	
	//picksphere
	pickSphere = Model::Sphere(12);
	pickSphere->SetScale(0.5);
	
	return true;
}

bool App::Loop()
{
	//Close the window to end the program
	if (window->Closed() || window->KeyHit(Key::Escape)) return false;
    
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
	
	//Place a new target position for our npc
	PickInfo pick;
	if (window->MouseHit(1))
    {
            PickInfo pickinfo;
            Vec3 p = window->GetMousePosition();
            if (camera->Pick(p.x,p.y,pickinfo,0,true))
            {
                    pickSphere->SetPosition(pickinfo.position);
					npc1->SetTarget(pickinfo.position);
            }
    }
	
	//Only check for destination if npc is walking
	if(npc1->state == NPC::State::WALKING)
		npc1->CheckDestination();

	//Allways chec the beggar
	beggar->CheckNPCDistance();


	Time::Update();
	world->Update();
	world->Render();
	context->Sync(false);
	
	return true;
}
