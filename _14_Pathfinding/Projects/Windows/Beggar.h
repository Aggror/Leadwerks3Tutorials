#pragma once

#include "Person.h"

class Beggar: public Person
{
public:
	Beggar(Person* player, Leadwerks::Vec3 startPos, float speed, float accelaration, float noticeDistance, float ignoreDistance);
	~Beggar();
	void CheckPlayerDistance();

	Person* player;
	float noticeDistance;
	float ignoreDistance;
};

