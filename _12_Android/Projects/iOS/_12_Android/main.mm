//
//  main.m
//  Interpreter
//
//  Created by Josh Klint on 11/5/12.
//  Copyright (c) 2012 Leadwerks Software. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"
#include "../../../Source/App.h"
#include "iOSFunctions.h"

void DebugErrorHook(char* c)
{
	Leadwerks::System::Print(c);
	exit(1);//Add a breakpoint here to catch errors
}

int main(int argc, char *argv[])
{
    @autoreleasepool {
        //Set directory
        std::string appdir = iOSGetAppPath("");
        chdir((appdir).c_str());
        
        //iOS will not consistently give the correct file path.  "/private" is not listed in iOSGetAppPath().
        appdir = Leadwerks::FileSystem::GetDir();
        
        Print(appdir+"/data.zip");
        Print(Leadwerks::FileSystem::RealPath(appdir+"/data.zip"));
        
		Leadwerks::System::AddHook(System::DebugErrorHook,(void*)DebugErrorHook);
		
        if (Leadwerks::Package::Load(appdir+"/data.zip")==NULL)
        {
            Leadwerks::Debug::Error("Failed to load application data package \""+appdir+"/data.zip\".");
        }
        chdir((appdir+"/data").c_str());
        
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
    
}
