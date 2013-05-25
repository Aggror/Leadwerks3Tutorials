#include "Beggar.h"

using namespace Leadwerks;

Beggar::Beggar(NPC* npc, Vec3 startPos, float speed, float accelaration, float noticeDistance, float ignoreDistance)
	: NPC(startPos, speed, accelaration)
{
	//Set variables
	this->npc = npc;
	state = State::IDLE;
	this->noticeDistance = noticeDistance;
	this->ignoreDistance = ignoreDistance;

	//Color the beggar red
	characterMesh->SetColor(1,0,0,0);
}

void Beggar::CheckNPCDistance()
{
	Vec3 beggarPos = characterController->GetPosition();
	Vec3 npcPos = npc->characterController->GetPosition();
	float npcDistanace = beggarPos.DistanceToPoint(npcPos);
	
	//Check if the npc is close the beggar, if it is, start following
	if(state == State::IDLE && npcDistanace < noticeDistance)
	{
		state = State::FOLLOWING;
		characterController->Follow(npc->characterController, speed, acceleration);

	}
	//If the npc is to far away then stop following him
	else if(state == State::FOLLOWING && npcDistanace > ignoreDistance)
	{
		//Stop following and go to idle
		characterController->Stop();
		state = State::IDLE;

	}
}

Beggar::~Beggar()
{
	delete npc;
}
