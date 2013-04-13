/*
#include "App.h"

using namespace Leadwerks;

App::App() : window(NULL), context(NULL), world(NULL), camera(NULL) {}

App::~App() { delete world; delete window; }

//Camera storage
Vec3 camRotation;
Vec2 centerMouse;
Vec2 mouseDifference;
float mouseSensitivity;

//Player
Entity* player;

//Speeds
Vec3 playerMovement;
float moveSpeed;
float strafeSpeed;

//jump and crouch
float jumpForce;
float tempJumpForce;
bool crouched;
float playerHeight;
float playerCrouchHeight;

//angles
float cameraTopAngle;
float cameraBottomAngle;
float camSmoothing;

bool App::Start()
{
	//Create a window
	window = Window::Create("_9_TPSController", 200, 0, 1024,768);
		
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
	centerMouse = Vec2(context->GetWidth()/2,context->GetHeight()/2 );
	window->SetMousePosition(centerMouse.x, centerMouse.y);
	mouseSensitivity = 15;

	//Create the player
	player = Pivot::Create();
	player->SetPosition(0,4,0);
    player->SetMass(5);
    player->SetPhysicsMode(Entity::CharacterPhysics);

	//Set some variables
	moveSpeed			= 6;
	strafeSpeed			= 4;
	crouched			= false;
	playerHeight		= 1.8;
	playerCrouchHeight	= 0.8;
	jumpForce			= 6;
	cameraTopAngle		= -45;
	cameraBottomAngle	= 80;
	camSmoothing		= 8.0;

	return true;
}

bool App::Loop()
{
	//Close the window to end the program
	if (window->Closed()||window->KeyHit(Key::Escape)) return false;
    
	//Get the mouse movement
	Vec3 currentMousePos = window->GetMousePosition();
	mouseDifference.x = currentMousePos.x - centerMouse.x;
	mouseDifference.y = currentMousePos.y - centerMouse.y;

	//Adjust and set the camera rotation
	float tempX = camRotation.x + (mouseDifference.y / mouseSensitivity);
	if(tempX > cameraTopAngle && tempX < cameraBottomAngle )
		camRotation.x = tempX;
	camRotation.y += mouseDifference.x / mouseSensitivity;
	camera->SetRotation(camRotation);
	window->SetMousePosition(centerMouse.x, centerMouse.y);

	//Player Movement
	playerMovement.x = (window->KeyDown(Key::D) - window->KeyDown(Key::A))	* Time::GetSpeed() * strafeSpeed;
	playerMovement.z = (window->KeyDown(Key::W) - window->KeyDown(Key::S))	* Time::GetSpeed() * moveSpeed;
	
	// Check for jumping
	tempJumpForce = 0;
	if(window->KeyHit(Key::Space) && !(player->GetAirborne()) )
			tempJumpForce = jumpForce;

	// Check for crouching
	if(window->KeyHit(Key::C))
		crouched = !crouched;

	//Update player
	player->SetInput(camRotation.y, playerMovement.z, playerMovement.x, tempJumpForce * Time::GetSpeed(), crouched, 1);

	//Position camera at correct height and playerPosition
	Vec3 tempFpsPos = camera->GetPosition();
	Vec3 playerPos = player->GetPosition();
	playerPos.y += (crouched ? playerCrouchHeight : playerHeight);
	tempFpsPos.y = Math::Curve(playerPos.y, tempFpsPos.y, camSmoothing * Time::GetSpeed());
	tempFpsPos = Vec3(playerPos.x, tempFpsPos.y ,playerPos.z);
	camera->SetPosition(tempFpsPos);

	Time::Update();
	world->Update();
	world->Render();

	context->Sync(true);

	return true;
}

*/