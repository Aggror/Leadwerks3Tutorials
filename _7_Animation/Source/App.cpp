#include "App.h"

using namespace Leadwerks;

App::App() : window(NULL), context(NULL), world(NULL), camera(NULL) {}

App::~App() { delete world; delete window; }


Model* barbarian;
enum BarbarianAnimation
{
	Dieing =	0,
	Idle =		1,
	Running =	2,
	Attack1 =	3,
	Attack2 =	4,
	Hurt =		5,
	Walking =	6

};
BarbarianAnimation barbAnim = BarbarianAnimation::Idle;
float animationSpeed;
float blend;

Vec3 camRot;
Pivot* camPivot;


bool App::Start()
{
	//Create a window
	window = Window::Create("_7_Animation", 100, 0, 1024, 768 );
	
	//Create a context
	context = Context::Create(window);
	
	//Create a world
	world = World::Create();

	Light* light = DirectionalLight::Create();
	light->SetRotation(45,45,0);
	
	//Create a camera
	camera = Camera::Create();
	camera->Move(0,2,-5);
	camPivot = Pivot::Create();
	window->HideMouse();


	//Load a model
	barbarian = Model::Load("Models/Barbarian/barbarian.mdl");
	barbarian->SetRotation(0,45,0);
	camRot = (0,0,-4);

	animationSpeed = 1.0;
	blend = 1.0;
	
	return true;
}

bool App::Loop()
{
	//Close the window to end the program
	if (window->Closed()||window->KeyHit(Key::Escape)) return false;
  
	//switch animations
	if(window->KeyHit(Key::A))
	{
		if(barbAnim - 1 < 0)
			barbAnim = BarbarianAnimation::Walking;
		else
			barbAnim = static_cast<BarbarianAnimation>(barbAnim - 1); 

		blend = 0;
	}
	if(window->KeyHit(Key::D))
	{
		if(barbAnim + 1 > 6)
			barbAnim = BarbarianAnimation::Dieing;
		else
			barbAnim = static_cast<BarbarianAnimation>(barbAnim + 1); 

		blend = 0;
	}
	//barbAnim = (barbAnim - 1  < 0 ? barbAnims::Walking : static_cast<barbAnims>(barbAnim - 1) );

	//Mouse controls
	if(window->MouseDown(1))
	{
		camRot.y += (window->MouseX() - (window->GetWidth()/2)) * Time::GetSpeed() * 0.2;
		camRot.x += (window->MouseY() - (window->GetHeight()/2)) * Time::GetSpeed() * 0.2;
	}
	if(window->MouseDown(2))
		camRot.z += (window->MouseY() - (window->GetHeight()/2)) * Time::GetSpeed() * 0.1;

	//Position camera at model
	Vec3 pos = barbarian->GetPosition();
	camera->SetPosition(pos.x, pos.y + 1, pos.z);
	camera->SetRotation(camRot.x, camRot.y, 0);
	camera->Move(0,0,camRot.z);
	window->SetMousePosition(window->GetWidth()/2,  window->GetHeight()/2);


	//Animate
	//float t = (Time::GetCurrent() / 100) * animationSpeed;
	//blend += 0.01 * Time::GetSpeed();
	//blend = 1;
	//barbarian->SetAnimationFrame(t , blend, barbAnim, true);


	float moving = window->KeyDown(Key::W);
	float attacking = window->KeyDown(Key::Enter);

	float t = (Time::GetCurrent() / 100) * animationSpeed;
	if(moving == 1 && attacking == 1)
	{
		//attack and run
		barbAnim = BarbarianAnimation::Running;
		barbarian->SetAnimationFrame(t , blend, barbAnim, true);
		barbAnim = BarbarianAnimation::Attack1;
		Entity* spine = barbarian->FindChild("BarbarianSpine1");
		spine->SetAnimationFrame(t , blend, barbAnim, true);
	}
	else if(moving == 1)
	{
		//just run
		barbAnim = BarbarianAnimation::Running;
		barbarian->SetAnimationFrame(t , blend, barbAnim, true);
	}
	else if(attacking == 1)
	{
		//just attack
		barbAnim = BarbarianAnimation::Attack1;
		barbarian->SetAnimationFrame(t , blend, barbAnim, true);
	}
	else
	{
		//idle
		barbAnim = BarbarianAnimation::Idle;
		barbarian->SetAnimationFrame(t , blend, barbAnim, true);
	}



	Time::Update();
	world->Update();
	world->Render();



	//Draw green color when visible and red when not visible
	context->SetColor(1,1,1);

	//Draw some text on screen
	context->SetBlendMode(Blend::Alpha);
		context->DrawText("Hold and move left mouse button to rotate." ,0, 0);
		context->DrawText("Hold and move right mouse button to zoom." ,0, 15);
		context->DrawText("Use A and D to cycle sequences. " ,0, 30);
		context->DrawText("Current animation sequence: " +  String(barbAnim), 0, 45);
	context->SetBlendMode(Blend::Solid);

	context->Sync(true);
	
	return true;
}
