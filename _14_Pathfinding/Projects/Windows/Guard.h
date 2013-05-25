#pragma once
#include "Person.h"

class Guard: public Person
{
public: 
	Guard(Leadwerks::Entity* path, Leadwerks::Vec3 startPos, float speed, float accelaration);
	~Guard();

	void CheckPathProgress();
	void GetAllWayPoints(Leadwerks::Entity* wayPointPath);
	list<Leadwerks::Entity*> wayPoints;
	list<Leadwerks::Entity*>::iterator currentIter;
};

