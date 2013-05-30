#pragma once
#include "Person.h"

class Guard: public Person
{
public: 
	Guard(Leadwerks::Entity* path, Leadwerks::Vec3 startPos, float speed, float accelaration);
	~Guard();

	void CheckPathProgress();
	void GetAllWayPoints(Leadwerks::Entity* wayPointPath);
	vector<Leadwerks::Vec3> wayPoints;
	int currentWaypoint;
};

