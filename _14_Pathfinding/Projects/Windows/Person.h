#pragma once

#include "Leadwerks.h"

class Person
{
public:
	Person();
	Person(Leadwerks::Vec3 startPos, float speed, float acceleration);
	~Person();

	void SetTarget(Leadwerks::Vec3 target);
	void CheckDestination();

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

