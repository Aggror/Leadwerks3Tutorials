//
//  AppDelegate.m
//  test
//
//  Created by Josh Klint on 11/7/12.
//  Copyright (c) 2012 Josh Klint. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#include "../../../Source/App.h"

@implementation AppDelegate

- (void)dealloc
{
    [_window release];
    [_viewController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.viewController = [[[ViewController alloc] initWithNibName:@"ViewController_iPhone" bundle:nil] autorelease];
    } else {
        self.viewController = [[[ViewController alloc] initWithNibName:@"ViewController_iPad" bundle:nil] autorelease];
    }
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
	return YES;
}

bool appwaspaused = false;

- (void)applicationWillResignActive:(UIApplication *)application
{
	appwaspaused = Leadwerks::timepausestate;
	
	//Relieve touch states
	for (int i=0; i<MaxTouches; i++)
	{
		activetouches[i]=NULL;
	}
	
#ifdef DEBUG
	//Leadwerks::Print("Application paused.");
#endif
	Leadwerks::Time::Pause();
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	//appwaspaused = Leadwerks::timepausestate;
//#ifdef DEBUG
	//Leadwerks::Print("Application paused.");
//#endif
	//Leadwerks::Time::Pause();
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
//#ifdef DEBUG
//	Leadwerks::Print("Application resumed.");
//#endif
//	if (!appwaspaused) Leadwerks::Time::Resume();
//	appwaspaused=false;
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
//#ifdef DEBUG
	//Leadwerks::Print("Application resumed.");
//#endif
	if (!appwaspaused) Leadwerks::Time::Resume();
	appwaspaused=false;
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    if (app)
	{
		delete app;
		app = NULL;
	}
}

@end
