// Main.mm 
// (c)2011 Leadwerks

// main entry point for MacOS app
// creates standard memory manager, menu and appdelegate
// calls testmain C++ entry point from -applicationDidFinishLaunching once cocoa app is fully initialised

#import <AppKit/AppKit.h>

#include "../../Source/App.h"

// declate app entry point
int main_(int argc, const char * argv[]);

// basic app menu required by a Cocoa app
static void createAppMenu( NSString *appName )
{	
	NSMenu *appMenu;
	NSMenuItem *item;
	NSString *title;
	
	[NSApp setMainMenu:[NSMenu new]];
	
	appMenu=[NSMenu new];
	
	title=[@"Hide" stringByAppendingString:appName];
	[appMenu addItemWithTitle:@"Hide" action:@selector(hide:) keyEquivalent:@"h"];
	
	item=(NSMenuItem*)[appMenu addItemWithTitle:@"Hide Others" action:@selector(hideOtherApplications:) keyEquivalent:@"h"];
	[item setKeyEquivalentModifierMask:(NSAlternateKeyMask|NSCommandKeyMask)];
	
	[appMenu addItemWithTitle:@"Show whatever All" action:@selector(unhideAllApplications:) keyEquivalent:@""];
	
	[appMenu addItem:[NSMenuItem separatorItem]];
	
	title=[@"Quit" stringByAppendingString:appName];
	[appMenu addItemWithTitle:title action:@selector(terminate:) keyEquivalent:@"q"];
	
	item=[NSMenuItem new];
	[item setSubmenu:appMenu];
	[[NSApp mainMenu] addItem:item];
	
	[NSApp performSelector:NSSelectorFromString(@"setAppleMenu:") withObject:appMenu];
}

@interface AppDelegate : NSObject <NSApplicationDelegate> {
	NSWindow *window;
}

@property (assign) IBOutlet NSWindow *window;

@end

@implementation AppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	main_(0,NULL);
	[NSApp terminate:nil];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender{
	return NSTerminateNow;
}

@end

int main(int argc, const char * argv[])
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	[NSApplication sharedApplication];
	
	createAppMenu(@"Test App");
	
	[NSApp setDelegate:[[AppDelegate alloc] init]];    
	[NSApp activateIgnoringOtherApps:YES];

    //Set the working directory
    std::string workingdir = std::string(argv[0]);
    workingdir = Leadwerks::FileSystem::ExtractDir(workingdir);
    workingdir = Leadwerks::FileSystem::ExtractDir(workingdir);
    workingdir = Leadwerks::FileSystem::ExtractDir(workingdir);
    workingdir = Leadwerks::FileSystem::ExtractDir(workingdir);
    Leadwerks::FileSystem::SetDir(workingdir);
    
    //Load command line arguments
    Leadwerks::System::ParseCommandLine(argc,argv);
    
	[NSApp run];
	
	[pool release];
	return 0;
}
