#include "Player.h"

Player::Player()
{
}

Player::Player(Leadwerks::Window* window, Leadwerks::Context* context, Leadwerks::Camera* camera)
{
	this->window = window;
	this->context = context;
	this->camera = camera;

	//Move the mouse to the center of the screen
	centerMouse = Leadwerks::Vec2(this->context->GetWidth()/2,context->GetHeight()/2 );
	this->window->SetMousePosition(centerMouse.x, centerMouse.y);
	mouseSensitivity =		15;

	//Create the player
	player = Leadwerks::Pivot::Create();
	player->SetPosition(0,4,0);
    player->SetMass(5);
    player->SetPhysicsMode(Leadwerks::Entity::CharacterPhysics);

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
}

void Player::Update()
{
	//Get the mouse movement
	Leadwerks::Vec3 currentMousePos = window->GetMousePosition();
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
	playerMovement.x = (window->KeyDown(Leadwerks::Key::D) - window->KeyDown(Leadwerks::Key::A))	* Leadwerks::Time::GetSpeed() * strafeSpeed;
	playerMovement.z = (window->KeyDown(Leadwerks::Key::W) - window->KeyDown(Leadwerks::Key::S))	* Leadwerks::Time::GetSpeed() * moveSpeed;
	
	// Check for jumping
	tempJumpForce = 0;
	if(window->KeyHit(Leadwerks::Key::Space) && !(player->GetAirborne()) )
			tempJumpForce = jumpForce;

	// Check for crouching
	if(window->KeyHit(Leadwerks::Key::C))
		crouched = !crouched;

	/* no smoothing
	//Update the player
	player->SetInput(camRotation.y, playerMovement.z, playerMovement.x, tempJumpForce , crouched, 1);
	Vec3 playerPos = player->GetPosition();
	float playerCamHeight = (crouched ? playerCrouchHeight : playerHeight);
	camera->SetPosition(playerPos.x, playerPos.y + playerCamHeight, playerPos.z);
	*/

	/* SMOOTHING*/
	//Position camera at correct height and playerPosition
	player->SetInput(camRotation.y, playerMovement.z, playerMovement.x, tempJumpForce , crouched, 1);
	Leadwerks::Vec3 playerPos = player->GetPosition();
	Leadwerks::Vec3 newCameraPos = camera->GetPosition();
	float playerTempHeight = (crouched ? playerCrouchHeight : playerHeight);
	newCameraPos.y = Leadwerks::Math::Curve(playerPos.y + playerTempHeight, newCameraPos.y, camSmoothing);
	newCameraPos = Leadwerks::Vec3(playerPos.x, newCameraPos.y ,playerPos.z);
	camera->SetPosition(newCameraPos);
	
}