#include "Guard.h"

using namespace Leadwerks;

Guard::Guard(Entity* path, Leadwerks::Vec3 startPos, float speed, float accelaration)
		: Person(startPos, speed, accelaration)
{
	//Color the guard green
	characterMesh->SetColor(0,1,0,0);
	state = State::WALKING;

	//Get all the waypoints 
	//GetAllWayPoints(path);

	//Set the first target
	currentIter = wayPoints.begin();
	//SetTarget((*currentIter)->GetPosition());
	SetTarget(Vec3(13,5,1));
}

void Guard::CheckPathProgress()
{
	//If we are close to the our target, set our target to the next on the list
	Vec3 guardPos = characterController->GetPosition();
	Vec3 targetPos = (*currentIter)->GetPosition();
	if(guardPos.DistanceToPoint(targetPos) < 1)
	{
		//If the currentTarget is is lower than the amount of waypoint we increase it, otherwise we go back to the first waypoint
		(currentIter != wayPoints.end()) ?  currentIter++ : currentIter = wayPoints.begin();
		SetTarget((*currentIter)->GetPosition());
	}
}

void Guard::GetAllWayPoints(Entity* wayPointPath)
{
	//Get the amount of children
	int children = wayPointPath->CountChildren();

	//Get all the children and store them in waypoints vector
	for (int i = 0; i < children; i++)
	{
		wayPoints.push_back(wayPointPath->GetChild(i));
	}

}


Guard::~Guard()
{
}
