#include "App.h"

using namespace Leadwerks;

App::App() : window(NULL), context(NULL), world(NULL), camera(NULL) {}

App::~App() { delete world; delete window; }

Model* ground;
Model* box1;
Model* box2;
Model* boxes[25];
Material* groundMaterial;
Material* stoneMaterial;

bool App::Start()
{
	//Create a window
	window = Window::Create("_3_Shapes");
	
	//Create a context
	context = Context::Create(window);
	
	//Create a world
	world = World::Create();
	
	//Create a camera
	camera = Camera::Create();
	camera->Move(0,2,-15);
	
	//Create ground and paint it with material
	groundMaterial = Material::Load("Materials/tile2.mat");
	ground = Model::Box(25,1,25);
	ground->SetMaterial(groundMaterial);
	ground->SetPosition(0,-2,0);

	Shape* groundShape = Shape::Box(0,0,0 ,0,0,0, 25,1,25);
	ground->SetShape(groundShape);
	groundShape->Release();
	ground->SetFriction(0, 0);

	//Create a box
	stoneMaterial = Material::Load("Materials/stone2.mat");	
	box1 = Model::Box();
	box1->SetMaterial(stoneMaterial);
	box1->SetPosition(0,3,0);

	Shape* boxShape = Shape::Box();
	box1->SetShape(boxShape);
	box1->SetMass(1);
	boxShape->Release();

	// Create a second box
	box2 = Model::Box();
	box2->SetMaterial(stoneMaterial);
	box2->SetPosition(0.2,2,0);

	Shape* box2Shape = Shape::Box();
	box2->SetShape(box2Shape);
	box2->SetMass(1);
	box2Shape->Release();
	
	//Create an array
	Shape* tempShape = Shape::Box();
	for(int i = 0; i<25;i++)
	{
		// Create a second box
		boxes[i] = Model::Box();
		boxes[i]->SetMaterial(stoneMaterial);
		boxes[i]->SetPosition(Math::Rnd(-2,2), 5 + (i * 2), Math::Rnd(-2,2));
		boxes[i]->SetShape(tempShape);
		boxes[i]->SetMass(1);
		boxes[i]->SetSweptCollisionMode(true);
	}
	tempShape->Release();
	return true;
}

bool App::Loop()
{
	//Close the window to end the program
	if (window->Closed()) return false;
  
	if(window->KeyHit(Key::A))
		box2->AddForce(-100,0,0);
	if(window->KeyHit(Key::D))
		box2->AddForce(100,0,0);

	Time::Update();
	world->Update();
	world->Render();
	context->Sync(false);
	
	return true;
}
