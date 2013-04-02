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

//once animation
float StartTimer;
float frameTime;
bool playAnimation;

//Camera controls
Vec3 camRot;
Pivot* camPivot;


bool App::Start()
{
	//Create a window
	window = Window::Create("_7_Animation", 100, 100, 1024, 768 );
	
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
	if(barbarian == NULL)
		cout << "asdf" <<endl;
	barbarian->SetRotation(0,45,0);
	camRot = (0,0,-4);

	animationSpeed = 1.0;
	blend = 1.0;

	//once animation
	StartTimer = 0;
	frameTime = 0;
	playAnimation = false;
	
	return true;
}

bool App::Loop()
{
	//Close the window to end the program
	if (window->Closed()||window->KeyHit(Key::Escape)) return false;
  
	/*
	//Check for P key to be hit
	if(window->KeyHit(Key::P) && playAnimation)
	{
		playAnimation = true;
		StartTimer = Time::GetCurrent() /100;
	}

	//Play animation once
	if(playAnimation)
	{
		frameTime = (Time::GetCurrent()/100) - StartTimer;

		//If the timer value is less than the length of the animation, we play the animation
		if(frameTime < barbarian->GetAnimationLength(BarbarianAnimation::Dieing))
			barbarian->SetAnimationFrame(frameTime , blend, BarbarianAnimation::Dieing, true);
		else
			playAnimation = false;
	}
	*/

	//switch animations
	if(window->KeyHit(Key::A))
	{
		//If the index is lower than 0, set the index back to the last animation sequence
		if(barbAnim - 1 < 0)
			barbAnim = BarbarianAnimation::Walking;
		else
			barbAnim = static_cast<BarbarianAnimation>(barbAnim - 1); 

		blend = 0;
	}
	if(window->KeyHit(Key::D))
	{
		//If the index is higher than the amount of animation sequences, set the index back to the first one
		if(barbAnim + 1 > 6)
			barbAnim = BarbarianAnimation::Dieing;
		else
			barbAnim = static_cast<BarbarianAnimation>(barbAnim + 1); 

		blend = 0;
	}

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

/*
	//Update Timer
	float t = (Time::GetCurrent() / 100) * animationSpeed;
	
	//increment Blending
	blend += 0.01 * Time::GetSpeed();
	blend = 1;
	if(blend > 1)
		blend = 1;
	barbarian->SetAnimationFrame(t , blend, barbAnim, true);

	//Simulate moving and attacking by storing the keys being pressed
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

	*/

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
		context->DrawText("Press P to play dieing animation once.", 0, 60);
	context->SetBlendMode(Blend::Solid);

	context->Sync(true);
	
	return true;
}