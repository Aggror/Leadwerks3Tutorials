//
//  ViewController.h
//  test
//
//  Created by Josh Klint on 11/7/12.
//  Copyright (c) 2012 Josh Klint. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

#include "../../../Source/App.h"

extern App* app;
extern bool appterminated;
extern const int MaxTouches;
extern UITouch* activetouches[11];

@interface ViewController : GLKViewController <UIAccelerometerDelegate>

@end
