#include "App.h"

using namespace Leadwerks;

App::App() : window(NULL), context(NULL), world(NULL), camera(NULL) {}

App::~App() { delete world; delete window; }

//Rope
const int size = 10;
Model* cylinders [size];
Model* jointSpheres [size];
Joint* ropeJoint; 
Material* ropeMat;

//Door
Model* doorPivot;
Model* door;
Joint* doorHinge;
Material* doorMat;

//Door
Pivot* slidingDoorPivot;
Model* slidingDoor;
Joint* slidingDoorJoint;
float offset;


bool App::Start()
{
	//Create a window
	window = Window::Create("_12_Joints");

	//Create a context
	context = Context::Create(window);

	//Create a world
	world = World::Create();

	//Create a camera
	camera = Camera::Create();
	camera->Move(0, 1, -4);
	camera->SetRotation(0,0,0);

	Light* light = DirectionalLight::Create();
	light->SetRotation(45,45,0);

	//load materials
	ropeMat = Material::Load("Materials/rope.mat");
	doorMat = Material::Load("Materials/door.mat");

	/*
	//Create cylinders, shapes and balljoints
	Shape* cylShape = Shape::Cylinder(0,0,0, 0,0,0, 1,1,1); 
	for(int i = 0; i < size; i++)
	{
	cylinders[i] = Model::Cylinder();
	cylinders[i]->SetMaterial(ropeMat);
	cylinders[i]->SetScale(0.1, 0.2, 0.1);
	if(i > 0)
	cylinders[i]->SetMass(1);
	cylinders[i]->SetShape(cylShape); 
	cylinders[i]->SetPosition(0, 3 + (-0.2 * i),-1);
	if(i > 0)
	{
	//Determine where the joints should be placed and create a ball joint
	float y = 3 + (-0.2 * i) + cylinders[i]->GetScale().y/2;
	ropeJoint = Joint::Ball(0, y, -1, cylinders[i], cylinders[i-1], 80);

	//Show spheres repre
	//jointSpheres[i] = Model::Sphere(8);
	//jointSpheres[i]->SetColor(0,255,0,0);
	//jointSpheres[i]->SetPosition(0,y,-1.2);
	//jointSpheres[i]->SetScale(0.1, 0.1, 0.1);
	}
	}
	cylShape->Release();
	*/

	//Door
	/*
	doorPivot = Model::Cylinder(9);
	doorPivot->SetScale(0.1, 2, 0.1);
	doorPivot->SetPosition(-1,0,0);
	Vec3 pp = doorPivot->GetPosition();
	doorPivot->SetMaterial(ropeMat);

	door = Model::Box(2,4,0.2);
	Shape* doorShape = Shape::Box(0,0,0,0,0,0,2,4,0.2);
	door->SetShape(doorShape);
	door->SetMass(20);
	door->SetMaterial(doorMat);

	doorHinge = Joint::Hinge(pp.x, pp.y, pp.z, 0, 1, 0, door, doorPivot, -45, 90);
	doorShape->Release();
	*/

	//Sliding door
	Shape* slideDoorShape = Shape::Box(0,0,0 ,0,0,0, 2,4,0.2);
	slidingDoorPivot = Pivot::Create();
	slidingDoorPivot->SetPosition(-2,0,0);
	slidingDoorPivot->SetRotation(0,30,0);
	slidingDoor = Model::Box(2,4,0.2);
	slidingDoor->SetShape(slideDoorShape);
	slidingDoor->SetMass(1);
	slidingDoor->SetPosition(-2,0,0);
	slidingDoor->SetRotation(0,30,0);
	slidingDoor->SetMaterial(doorMat);
	slidingDoorJoint = Joint::Slider(0,0,0, 1,0,0, slidingDoor,slidingDoorPivot,-2, 2);
	slidingDoorJoint->SetRotation(0,30,0, true);
	slideDoorShape->Release();

	//camera->drawphysicsmode = true;
	return true;
}

bool App::Loop()
{
	//Close the window to end the program
	if (window->Closed()) return false;

	float ropeForce = window->KeyDown(Key::D) - window->KeyDown(Key::A);
	//cylinders[size - 1]->AddForce(ropeForce* Time::GetSpeed() * 2,0,0);

	float doorForce = window->KeyDown(Key::W) - window->KeyDown(Key::S);
	//door->AddForce(ropeForce* Time::GetSpeed() * 100, 0, doorForce* Time::GetSpeed() * 100);

	float sliderForce = window->KeyDown(Key::E) - window->KeyDown(Key::Q);
	slidingDoor->AddForce(sliderForce* Time::GetSpeed() * 2,0,0);


	Time::Update();
	world->Update();
	world->Render();
	context->Sync(false);

	return true;
}


