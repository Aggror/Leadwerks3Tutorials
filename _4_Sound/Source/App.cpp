#include "App.h"

using namespace Leadwerks;

App::App() : window(NULL), context(NULL), world(NULL), camera(NULL) {}

App::~App() { delete world; delete window; }

Source* s_guitar;

bool App::Start()
{
	//Create a window
	window = Window::Create("_4_Sound");
	
	//Create a context
	context = Context::Create(window);
	
	//Create a world
	world = World::Create();
	
	//Load soundsSound* engine;
	Sound* guitar = Sound::Load("Sounds/guitar.wav");
	//guitar->Play();

	//Create source
	s_guitar = Source::Create();
	s_guitar->SetSound(guitar);
	s_guitar->SetLoopMode(true);
	s_guitar->Play();
	guitar->Release();

	return true;
}

bool App::Loop()
{
	//Close the window to end the program
	if (window->Closed()) return false;

    //Press space key to pause/resume sound
    if (window->KeyHit(Key::Space))
    {
            if (s_guitar->GetState()==Source::Paused)
                    s_guitar->Resume();
            else
                    s_guitar->Pause(); 
    }

	//Change Volume
	if (window->KeyHit(Key::Q))
		s_guitar->SetVolume(s_guitar->volume - 0.1);
	else if (window->KeyHit(Key::E))
        s_guitar->SetVolume(s_guitar->volume + 0.1);

	//Change pitch
	if (window->KeyHit(Key::A))
		s_guitar->SetPitch(s_guitar->pitch - 0.1);
	else if (window->KeyHit(Key::D))
        s_guitar->SetPitch(s_guitar->pitch + 0.1);	

	Time::Update();
	world->Update();
	world->Render();

	//Draw info on screen
	context->Clear();
	context->SetBlendMode(Blend::Alpha);
		context->SetColor(1,1,1);
		context->DrawText("Press SPACE to resume/play.", 0,0 );
		context->DrawText("Press Q and E to change volume  :: " + String(s_guitar->GetPitch()), 0,20 );
		context->DrawText("Press A and D to change pitch   :: " + String(s_guitar->volume), 0,40 );
	context->SetBlendMode(Blend::Solid);
	context->SetColor(0,0,0);
	context->Sync(false);

	return true;
}
