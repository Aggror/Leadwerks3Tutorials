#include "App.h"

using namespace Leadwerks;

App::App() : window(NULL), context(NULL), world(NULL), camera(NULL) {}

App::~App() { delete world; delete window; }

Vec3 leftPoint;
Vec3 rightPoint;
Model* box1;
Model* box2;
Model* box3;
float pickRadius;
Model* sphere;

bool App::Start()
{
	//Create a window
	window = Window::Create("_6_Raycasting", 100, 100, 1024,768);
	
	//Create a context
	context = Context::Create(window);
	
	//Create a world
	world = World::Create();
	
	//Create a camera
	camera = Camera::Create();
	camera->Move(0,1,-5);
	
	//Light
	Light* light= DirectionalLight::Create();
	light->SetRotation(45,45,45);

	//Create points
	leftPoint = Vec3(-4,0,0);
	rightPoint = Vec3(4,0,0);

	//Create the boxes
	box1 = Model::Box();
	box1->SetColor(1.0, 0.0, 0.0);
	box1->SetPosition(-2,1,0);
	box1->SetKeyValue("Icecream","Vanilla");

	// Pickmode = 0
	box2 = Model::Box();
	box2->SetColor(0.0, 1.0, 0.0);
	box2->SetPosition(0,1,0);
	//box2->SetPickMode(0);

	//Collision type = 5
	box3 = Model::Box();
	box3->SetColor(0.0, 0.0, 1.0);
	box3->SetPosition(2,1,0);
	box3->SetCollisionType(5);
	box3->SetKeyValue("Icecream","Chocolate");
	

	//Set the radius
	pickRadius = 0.2f;

	//Create a test sphere to show pickinfo
	sphere = Model::Sphere();
	sphere->SetScale(0.3, 0.3, 0.3);
	sphere->SetPosition(-3,1,0);
	sphere->SetPickMode(0);

	return true;
}

bool App::Loop()
{
	//Close the window to end the program
	if (window->Closed()|| window->KeyHit(Key::Escape)) return false;
    
	//Keyboard movement
	float move1 = (window->KeyDown(Key::Q) - window->KeyDown(Key::A))*Time::GetSpeed() * 0.05;
	float move2 = (window->KeyDown(Key::W) - window->KeyDown(Key::S))*Time::GetSpeed() * 0.05;
	float move3 = (window->KeyDown(Key::E) - window->KeyDown(Key::D))*Time::GetSpeed() * 0.05;
	box1->Translate(0,move1,0);
	box2->Translate(0,move2,0);
	box3->Translate(0,move3,0);

	//Pick
	PickInfo pickInfo;
	bool visible = true;
	
	if (world->Pick(leftPoint, rightPoint, pickInfo, pickRadius))
    {
		visible = false;
        sphere->SetPosition(pickInfo.position);
		if(pickInfo.entity->GetKeyName(0) == "Icecream")
		//if(pickInfo.entity->GetKeyValue("Icecream") == "Chocolate")
			pickInfo.entity->Turn(0,0,0.5 * Time::GetSpeed());
    }
	else
		sphere->SetPosition(-3,1,0);

	Time::Update();
	world->Update();
	world->Render();

	//Transform 3d positions to 2d position
	Vec3 p1 = camera->Project(leftPoint);
	Vec3 p2 = camera->Project(rightPoint);
	Vec3 radiusTopProjection = camera->Project(Vec3(0,leftPoint.y + pickRadius,0));
	Vec3 radiusLowProjection = camera->Project(Vec3(0,leftPoint.y - pickRadius,0));

	//Draw green color when visible and red when not visible
	if(visible)
		context->SetColor(0,1,0);
	else
		context->SetColor(1,0,0);

	//Draw 1 or 2 lines depending on pick radius
	if(pickRadius > 0.0f)
	{
		context->DrawLine(p1.x, radiusTopProjection.y, p2.x, radiusTopProjection.y);
		context->DrawLine(p1.x, radiusLowProjection.y, p2.x, radiusLowProjection.y);
	}
	else
		context->DrawLine(p1.x, p1.y, p2.x, p2.y);

	//Draw some text on screen
	context->SetBlendMode(Blend::Alpha);
		context->DrawText("Visible: " + String(visible) ,0,0);
	context->SetBlendMode(Blend::Solid);

	context->Sync(true);
	
	return true;
}