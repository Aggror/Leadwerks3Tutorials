#include "Person.h"

using namespace Leadwerks;

Person::Person()
{
}

Person::Person(Vec3 startPos, float speed, float acceleration)
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

void Person::SetTarget(Vec3 target)
{
	//set the target where the player has to walk to.
	currentTarget = target;
	characterController->GoToPoint(target, speed, acceleration);
	state = State::WALKING;
}

void Person::CheckDestination()
{
	//Stop the player when he gets close to the destination
	if (characterController->GetPosition().DistanceToPoint(currentTarget)<1.0)
	{
		//stop walking
		characterController->Stop();
		state = State::IDLE;
	}
}
	
Person::~Person()
{	
	characterController->Release();
	characterMesh->Release();
}
