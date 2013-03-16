#include "App.h"

using namespace Leadwerks;

App::App() : window(NULL), context(NULL), world(NULL), camera(NULL) {}

App::~App() { delete world; delete window; }

Model* box;
Model* cylinder;
Model* sphere;
Model* cone;
Model* pumpkin;
Material* pumpkinMaterial;

DirectionalLight* light;

bool App::Start()
{
	//Create a window
	window = Window::Create("_2_Models");
	
	//Create a context
	context = Context::Create(window);
	
	//Create a world
	world = World::Create();
	
	//Create a camera
	camera = Camera::Create();
	camera->Move(0,2,-5);
	
	//Create models
	box = Model::Box(1, 0.2, 3);
	box->SetPosition(-3, 0, 0);

	sphere = Model::Sphere(8);
	sphere->SetPosition(0, 0, 0);

	cylinder = Model::Cylinder(32);
	cylinder->SetPosition(3, 0, 0);

	cone = Model::Cone(8);
	cone->SetPosition(6, 0, 0);

	//Pumpkin
	pumpkin = Model::Load("Models/pumpkin.mdl");
	pumpkin->SetPosition(0, 0, 2);
	pumpkinMaterial = Material::Load("Models/pumpkin.mat");
	pumpkin->SetMaterial(pumpkinMaterial);


	//Create light
	light = DirectionalLight::Create(camera);
	light->SetRotation(45,45,0);

	return true;
}

bool App::Loop()
{
	//Close the window to end the program
	if (window->Closed()) return false;
    
	if(window->KeyDown(Key::A))
		camera->Move(Vec3(-0.1 * Time::GetSpeed(),0,0));
	if(window->KeyDown(Key::D))
		camera->Move(Vec3(0.1 * Time::GetSpeed(),0,0));

	Time::Update();
	world->Update();
	world->Render();

	context->DrawImage(pumpkinMaterial->GetTexture(), 0, 0, 250, 250);

	context->Sync(false);
	
	return true;
}
