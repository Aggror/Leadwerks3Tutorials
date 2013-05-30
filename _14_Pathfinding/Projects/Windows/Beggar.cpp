#include "Beggar.h"

using namespace Leadwerks;

Beggar::Beggar(Person* player, Vec3 startPos, float speed, float accelaration, float noticeDistance, float ignoreDistance)
	: Person(startPos, speed, accelaration)
{
	//Set variables
	this->player = player;
	state = State::IDLE;
	this->noticeDistance = noticeDistance;
	this->ignoreDistance = ignoreDistance;

	//Color the beggar red
	characterMesh->SetColor(1,0,0,0);
}

void Beggar::CheckPlayerDistance()
{
	//Retrieve distance between beggar and player
	Vec3 beggarPos = characterController->GetPosition();
	Vec3 playerPos = player->characterController->GetPosition();
	float playerDistanace = beggarPos.DistanceToPoint(playerPos);
	
	//Check if the player is close the beggar, if it is, start following
	if(state == State::IDLE && playerDistanace < noticeDistance)
	{
		state = State::FOLLOWING;
		characterController->Follow(player->characterController, speed, acceleration);

	}
	//If the player is to far away then stop following him
	else if(state == State::FOLLOWING && playerDistanace > ignoreDistance)
	{
		//Stop following and go to idle
		characterController->Stop();
		state = State::IDLE;

	}
}

Beggar::~Beggar()
{
}
