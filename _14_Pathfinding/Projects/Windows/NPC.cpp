#include "NPC.h"

using namespace Leadwerks;

NPC::NPC()
{
}

NPC::NPC(Vec3 startPos, float speed, float acceleration)
{
	this->speed = speed;
	this->acceleration = acceleration;
	state = State::IDLE;

	 //Create a character controller and attach a mesh
	characterController = Pivot::Create();
	characterController->SetPosition(startPos);
	characterMesh = Model::Cylinder(16,characterController);
	characterMesh->SetScale(1,2,1);
	characterMesh->SetPosition(0,1,0);
    characterController->SetMass(1);
    characterController->SetPhysicsMode(Entity::CharacterPhysics);
}

void NPC::SetTarget(Vec3 target)
{
	currentTarget = target;
	characterController->GoToPoint(target, speed, acceleration);
	state = State::WALKING;
}

void NPC::CheckDestination()
{
	//Stop the player when he gets close to the destination
	if (characterController->GetPosition().DistanceToPoint(currentTarget)<1.0)
	{
		//stop walking
		characterController->Stop();
		state = State::IDLE;
	}
}
	

NPC::~NPC()
{	
	characterController->Release();
	characterMesh->Release();
}
