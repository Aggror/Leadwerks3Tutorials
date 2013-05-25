#pragma once

#include "Leadwerks.h"


class NPC
{
public:
	NPC();
	NPC(Leadwerks::Vec3 startPos, float speed, float acceleration);
	~NPC();


	void SetTarget(Leadwerks::Vec3 target);
	void CheckDestination();

	//list<Leadwerks::Entity*>waypoints;
	Leadwerks::Vec3 currentTarget;

	Leadwerks::Pivot* characterController;
	Leadwerks::Model* characterMesh;
	float speed;
	float acceleration;

	//FSM
	enum State
	{
		IDLE = 0,
		WALKING,
		FOLLOWING
	};
	State state;


};

