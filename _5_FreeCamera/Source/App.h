#pragma once
#include "Leadwerks.h"

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
};
