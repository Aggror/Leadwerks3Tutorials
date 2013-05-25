#pragma once

#include "NPC.h"

class Beggar: public NPC
{
public:
	Beggar(NPC* npc, Leadwerks:: Vec3 startPos, float speed, float accelaration, float noticeDistance, float ignoreDistance);
	~Beggar();
	void CheckNPCDistance();

	NPC* npc;
	float noticeDistance;
	float ignoreDistance;
};

