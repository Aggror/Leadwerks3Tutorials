#include "App.h"

using namespace Leadwerks;

App::App() : window(NULL), context(NULL), world(NULL), camera(NULL) {}

App::~App() { delete world; delete window; }

bool App::Start()
{
    int stacksize = Interpreter::GetStackSize();
	
    //Create new table and assign it to the global variable "App"
    Interpreter::NewTable();
    Interpreter::SetGlobal("App");
    
    //Invoke the start script
    if (!Interpreter::ExecuteFile("Scripts/App.lua"))
    {
        Print("Error: Failed to execute script \"Scripts/App.lua\".");
        return false;
    }
    
    //Call the App:Start() function
    Interpreter::GetGlobal("App");
    if (Interpreter::IsTable())
    {
        Interpreter::PushString("Start");
        Interpreter::GetTable();
        if (Interpreter::IsFunction())
        {
            Interpreter::PushValue(-2);//Push the app table onto the stack as "self"
			if (!Interpreter::Invoke(1,1,0)) return false;
            if (Interpreter::IsBool())
            {
                if (!Interpreter::ToBool()) return false;
            }
            else
            {
                return false;
            }
        }
    }
    
    //Restore the stack size
    Interpreter::SetStackSize(stacksize);
    
    return true;
}

bool App::Loop()
{
	if (Window::GetCurrent()->KeyDown(Key::R))
	{
		std::list<Asset*>::iterator it;
		for (it=Asset::List.begin(); it!=Asset::List.end(); it++)
		{
			Asset* asset = (*it);
			if (asset->GetClassName()=="Texture") asset->Reload();
		}
	}

    //Get the stack size
    int stacksize = Interpreter::GetStackSize();
	
    //Call the App:Start() function
    Interpreter::GetGlobal("App");
    if (Interpreter::IsTable())
    {
        Interpreter::PushString("Loop");
        Interpreter::GetTable();
        if (Interpreter::IsFunction())
        {
            Interpreter::PushValue(-2);//Push the app table onto the stack as "self"
            if (!Interpreter::Invoke(1,1,0))
            {
                Print("Error: Script function App:Loop() was not successfully invoked.");
                Interpreter::SetStackSize(stacksize);
                return false;
            }
            if (Interpreter::IsBool())
            {
                if (!Interpreter::ToBool())
                {
                    Interpreter::SetStackSize(stacksize);
                    return false;
                }
            }
            else
            {
                Interpreter::SetStackSize(stacksize);
                return false;
            }
        }
        else
        {
            Print("Error: App:Loop() function not found.");
            Interpreter::SetStackSize(stacksize);
            return false;
        }
    }
    else
    {
        Print("Error: App table not found.");
        Interpreter::SetStackSize(stacksize);
        return false;
    }
    
    //Restore the stack size
    Interpreter::SetStackSize(stacksize);
    
    return true;
}
