#ifndef OS_IOS
	#ifndef _DLL
		#ifndef BUILD_STATICLIB
			#include "App.h"
		#endif
	#endif

using namespace Leadwerks;

void DebugErrorHook(char* c)
{
	Leadwerks::System::Print(c);
	exit(1);//Add a breakpoint here to catch errors
}

    #ifdef __APPLE__
int main_(int argc,const char *argv[])
{
	#else
int main(int argc,const char *argv[])
{
	System::ParseCommandLine(argc,argv);
	#endif 
	
	Leadwerks::System::AddHook(System::DebugErrorHook,(void*)DebugErrorHook);
	
    //Load any zip files in main directory
    Leadwerks::Directory* dir = Leadwerks::FileSystem::LoadDir(".");
    if (dir)
    {
        for (int i=0; i<dir->files.size(); i++)
        {
            std::string file = dir->files[i];
            if (Leadwerks::String::Lower(Leadwerks::FileSystem::ExtractExt(file))=="zip")
            {
                Leadwerks::Package::Load(file);
            }
        }
        delete dir;
    }
    
    #ifdef DEBUG
	std::string debuggerhostname = System::GetProperty("debuggerhostname");
	if (debuggerhostname!="")
	{
		//Connect to the debugger
		int debuggerport = String::Int(System::GetProperty("debuggerport"));		
		if (!Interpreter::Connect(debuggerhostname,debuggerport))
		{
			Print("Error: Failed to connect to debugger with hostname \""+debuggerhostname+"\" and port "+String(debuggerport)+".");
			return false;
		}
		Print("Successfully connected to debugger.");
		std::string breakpointsfile = System::GetProperty("breakpointsfile");
		if (breakpointsfile!="")
		{
			if (!Interpreter::LoadBreakpoints(breakpointsfile))
			{
				Print("Error: Failed to load breakpoints file \""+breakpointsfile+"\".");
			}
		}
	}
    else
    {
    //    Print("No debugger hostname supplied in command line.");
    }
#endif
	App* app = new App;
 	if (app->Start())
	{
		while (app->Loop()) {}
	#ifdef DEBUG
		Interpreter::Disconnect();
	#endif
		delete app;
		return 0;
	}
	else
	{	
	#ifdef DEBUG
		Interpreter::Disconnect();
	#endif
		return 1;
	}
}
#endif
