#include "App.h"

using namespace Leadwerks;

App::App() : window(NULL), context(NULL), world(NULL), camera(NULL) {}

App::~App() { delete world; delete window; }

Vec3 camRotation;
Vec2 centerMouse;
Vec2 mouseDifference;
Vec3 camMovement;
float mouseSensitivity;

float moveMultiplier;
float strafeMultiplier;

Model* spectator;
bool cameraPhysics;
float forceMultiplier;

bool debugPhysics;

bool App::Start()
{
	//Create a window
	window = Window::Create("_5_FreeCamera");
	
	//Create a context
	context = Context::Create(window);
	
	//Create a world
	world = World::Create();
	
	//Create a camera
	camera = Camera::Create();
	camera->Move(0,2,-5);
	
	//Hide the mouse cursor
	window->HideMouse();
	
	//Load a map
	Map::Load("Maps/start.map");
	
	//Move the mouse to the center of the screen
	centerMouse = Vec2(context->GetWidth()/2,context->GetHeight()/2 );
	window->SetMousePosition(centerMouse.x, centerMouse.y);
	mouseSensitivity =		15;

	moveMultiplier =		0.3;
	strafeMultiplier =		0.2;
	forceMultiplier =		1000;

	//Create cam shapes
	spectator = Model::Sphere(8);
	spectator->SetScale(5,5,5);
	spectator->SetPosition(0,8,8);
	Shape* sphereShape = Shape::Sphere(0,0,0, 0,0,0, 1,1,1);
	spectator->SetShape(sphereShape);
	spectator->SetCollisionType(Collision::Prop);
	spectator->SetGravityMode(false);
	spectator->SetMass(1);
	sphereShape->Release();
	//spectator->Hide();

	//Start without cameraPhysics
	cameraPhysics = false;
	return true;
}

bool App::Loop()
{
	//Close the window to end the program
	if (window->Closed()||window->KeyHit(Key::Escape))
		return false;

	//Debug physics
	if(window->KeyHit(Key::P))
		camera->drawphysicsmode = !camera->drawphysicsmode;

	if(window->KeyHit(Key::C))
	{
		cameraPhysics = !cameraPhysics;
		if(cameraPhysics)
			spectator->SetPosition(camera->GetPosition());
	}

	//Keyboard movement
	camMovement.x = (window->KeyDown(Key::D) - window->KeyDown(Key::A))	* Time::GetSpeed() * strafeMultiplier;
	camMovement.y = (window->KeyDown(Key::E) - window->KeyDown(Key::Q))	* Time::GetSpeed() * strafeMultiplier;
	camMovement.z = (window->KeyDown(Key::W) - window->KeyDown(Key::S))	* Time::GetSpeed() * moveMultiplier;
    
	if(cameraPhysics == 1)
	{
		camera->SetPosition(spectator->GetPosition());
		Vec3 newForce = Transform::Vector(camMovement, camera, 0);
		spectator->AddForce(newForce * forceMultiplier);
	}
	else
		camera->Move(camMovement);

	//Get the mouse movement
	Vec3 currentMousePos = window->GetMousePosition();
	mouseDifference.x = currentMousePos.x - centerMouse.x;
	mouseDifference.y = currentMousePos.y - centerMouse.y;

	//Adjust and set the camera rotation
	camRotation.x += mouseDifference.y / mouseSensitivity;
	camRotation.y += mouseDifference.x / mouseSensitivity;
	camera->SetRotation(camRotation);

	//Move the mouse to the center of the screen
	window->SetMousePosition(centerMouse.x, centerMouse.y);
	
	Time::Update();
	world->Update();
	world->Render();

	context->SetBlendMode(Blend::Alpha);
	context->DrawText("Camera physics: " + String(cameraPhysics),0,0);

	context->Sync(false);
	
	return true;
}
