#pragma once
#include "Leadwerks.h"
#include "Player.h"

using namespace Leadwerks;

class App
{
public:
	Window* window;
	Context* context;
	World* world;
	Camera* camera;

	App();
	virtual ~App();
	
    virtual bool Start();
    virtual bool Loop();
	
	Player myPlayer;

};
