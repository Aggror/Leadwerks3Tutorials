//
//  ViewController.m
//  test
//
//  Created by Josh Klint on 11/7/12.
//  Copyright (c) 2012 Josh Klint. All rights reserved.
//

#import "ViewController.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

bool appterminated = false;
bool started = false;
App* app = NULL;

// Uniform index.
enum
{
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    UNIFORM_NORMAL_MATRIX,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

// Attribute index.
enum
{
    ATTRIB_VERTEX,
    ATTRIB_NORMAL,
    NUM_ATTRIBUTES
};


@interface ViewController () {
    GLuint _program;
    
    GLKMatrix4 _modelViewProjectionMatrix;
    GLKMatrix3 _normalMatrix;
    float _rotation;
    
    GLuint _vertexArray;
    GLuint _vertexBuffer;
}
@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;

- (void)tearDownGL;

@end

@implementation ViewController

const int MaxTouches = 11;
UITouch* activetouches[11]={NULL};

- (void) touchesEnded: (NSSet *) touches withEvent: (UIEvent *) event
{
	int i;
	for (UITouch *touch in touches)
    {
		for (i=0; i<MaxTouches; i++)
		{
			if (activetouches[i]==touch)
			{
				activetouches[i]=NULL;
				Leadwerks::Window::TouchDownState[i]=false;
				CGPoint touchPoint = [touch locationInView:self.view];
				Leadwerks::Window::TouchPosition[i].x=touchPoint.x;
				Leadwerks::Window::TouchPosition[i].y=touchPoint.y;
				//printf("Touch up: %i",i);
				break;
			}
		}
    }
    [super touchesEnded: touches withEvent: event];
}

- (void) touchesMoved: (NSSet *) touches withEvent: (UIEvent *) event
{
	int i;
	for (UITouch *touch in touches)
    {
		for (i=0; i<MaxTouches; i++)
		{
			if (activetouches[i]==touch)
			{
				CGPoint touchPoint = [touch locationInView:self.view];
				Leadwerks::Window::TouchPosition[i].x=touchPoint.x;
				Leadwerks::Window::TouchPosition[i].y=touchPoint.y;
				break;
			}
		}
    }
    [super touchesMoved: touches withEvent: event];
}

- (void) touchesBegan: (NSSet *) touches withEvent: (UIEvent *) event
{
	int i;
	for (UITouch *touch in touches)
    {
		for (i=0; i<MaxTouches; i++)
		{
			if (activetouches[i]==NULL)
			{
				activetouches[i]=touch;
				Leadwerks::Window::TouchDownState[i]=true;
				Leadwerks::Window::TouchHitState[i]=true;
				CGPoint touchPoint = [touch locationInView:self.view];
				Leadwerks::Window::TouchPosition[i].x=touchPoint.x;
				Leadwerks::Window::TouchPosition[i].y=touchPoint.y;
				//printf("Touch down: %f, %f",touchPoint.x,touchPoint.y);
				break;
			}
		}
    }
    [super touchesBegan: touches withEvent: event];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    //Get device orientation and resolution
    UIInterfaceOrientation orientation = self.interfaceOrientation;
    CGRect cgRect =[[UIScreen mainScreen] bounds];
    
    switch (orientation)
    {
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            Leadwerks::iOSScreenWidth = cgRect.size.height * view.contentScaleFactor;
            Leadwerks::iOSScreenHeight = cgRect.size.width * view.contentScaleFactor;
            break;
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            Leadwerks::iOSScreenWidth = cgRect.size.width * view.contentScaleFactor;
            Leadwerks::iOSScreenHeight = cgRect.size.height * view.contentScaleFactor;
            break;
    }
    
    //Get the specific screen orientation, for adjusting the acceleration
    switch (orientation)
    {
        case UIInterfaceOrientationLandscapeLeft:
            Leadwerks::Device::iOSOrientation = Leadwerks::Device::LandscapeLeft;
            break;
        case UIInterfaceOrientationLandscapeRight:
            Leadwerks::Device::iOSOrientation = Leadwerks::Device::LandscapeRight;
            break;
        case UIInterfaceOrientationPortrait:
            Leadwerks::Device::iOSOrientation = Leadwerks::Device::Portrait;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            Leadwerks::Device::iOSOrientation = Leadwerks::Device::PortraitUpsideDown;
            break;
    }
    
    //Calculate average acceleration.  Since framerate is 60 and the accelerometer updates at 30 hz, this probably has no smoothing effect.
    if (Leadwerks::Device::IOSAccumulatedAccelerationsCount>0)
    {
        Leadwerks::Device::acceleration = Leadwerks::Device::IOSAccumulatedAccelerations / (float)Leadwerks::Device::IOSAccumulatedAccelerationsCount;
        
        //Reset accumulated accelerations
        Leadwerks::Device::IOSAccumulatedAccelerationsCount = 0;
        Leadwerks::Device::IOSAccumulatedAccelerations.x = 0;
        Leadwerks::Device::IOSAccumulatedAccelerations.y = 0;
        Leadwerks::Device::IOSAccumulatedAccelerations.z = 0;
    }
    
    //Start application
    if (!started)
    {
		app = new App;
        if (!app->Start())
        {
            appterminated=true;
            delete app;
			app=NULL;
        }
        started=true;
    }
    
    //Continue application
    if (!appterminated)
    {
		if (app)
		{
			if (!app->Loop())
			{
				appterminated=true;
				delete app;
				app = NULL;
			}
		}
    }
}

- (NSUInteger)preferredInterfaceOrientations
{
	if (Leadwerks::Device::orientation==Leadwerks::Device::Portrait)
	{
		return UIInterfaceOrientationMaskPortrait;
	}
	else
	{
		return UIInterfaceOrientationMaskLandscape;
	}
}

- (NSUInteger)supportedInterfaceOrientations
{
	if (Leadwerks::Device::orientation==Leadwerks::Device::Portrait)
	{
			return UIInterfaceOrientationMaskPortrait;
	}
	else
	{
		return UIInterfaceOrientationMaskLandscape;
	}
}

//Obsolete as of iOS 6
/*- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    switch(interfaceOrientation)
    {
        case UIInterfaceOrientationPortrait:
            if (Leadwerks::Device::orientation==Leadwerks::Device::Portrait) return YES;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            if (Leadwerks::Device::orientation==Leadwerks::Device::Portrait) return YES;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            if (Leadwerks::Device::orientation==Leadwerks::Device::Landscape) return YES;
            break;
        case UIInterfaceOrientationLandscapeRight:
            if (Leadwerks::Device::orientation==Leadwerks::Device::Landscape) return YES;
            break;
    }
    return NO;
}*/

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
    Leadwerks::Device::IOSAccumulatedAccelerations.x += acceleration.x;
    Leadwerks::Device::IOSAccumulatedAccelerations.y += acceleration.y;
    Leadwerks::Device::IOSAccumulatedAccelerations.z += acceleration.z;
    Leadwerks::Device::IOSAccumulatedAccelerationsCount++;
    
    //le3::Print(le3::String(acceleration.x));
    //le3::Print(le3::String(acceleration.y));
    //le3::Print(le3::String(acceleration.z));
    //le3::Print("");
    //le3::Mat4 mat;
    //le3::Vec3 v = le3::Vec3(acceleration.x,acceleration.y,acceleration.z);
    //mat.MakeDir(v,AXIS_Y);
    //le3::Device::rotation = le3::Vec3(mat.GetRotation());
}

- (void)dealloc
{
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
    
    [_context release];
    [_effect release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	//Enable accelerometer
    [[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / 30.0)];
    [[UIAccelerometer sharedAccelerometer] setDelegate:self];
	
	//Enable multitouch events
    self.view.multipleTouchEnabled = YES;
	
    self.context = [[[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2] autorelease];
    
    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
	//Set framerate here to 30 or 60
	self.preferredFramesPerSecond=60;
	
    //Comment this line out to support native resolution for retina displays:
    view.contentScaleFactor = 1.0;
    
    [EAGLContext setCurrentContext:self.context];
    self.effect = [[[GLKBaseEffect alloc] init] autorelease];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    if ([self isViewLoaded] && ([[self view] window] == nil)) {
        self.view = nil;
        
        [self tearDownGL];
        
        if ([EAGLContext currentContext] == self.context) {
            [EAGLContext setCurrentContext:nil];
        }
        self.context = nil;
    }

    // Dispose of any resources that can be recreated.
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    
    glDeleteBuffers(1, &_vertexBuffer);
    glDeleteVertexArraysOES(1, &_vertexArray);
    
    self.effect = nil;
    
    if (_program) {
        glDeleteProgram(_program);
        _program = 0;
    }
}

/*- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glBindVertexArrayOES(_vertexArray);
    
    // Render the object with GLKit
    [self.effect prepareToDraw];
    
    glDrawArrays(GL_TRIANGLES, 0, 36);
    
    // Render the object again with ES2
    glUseProgram(_program);
    
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _modelViewProjectionMatrix.m);
    glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, _normalMatrix.m);
 
    glDrawArrays(GL_TRIANGLES, 0, 36);
}*/

@end
