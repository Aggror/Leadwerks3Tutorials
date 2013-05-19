/*
 *  TombstoneiPhoneFunctions.h
 *  FreeFalling
 *
 *  Created by EdzUp on 17/03/2010.
 *  Copyright 2010 Graveyard Dogs. All rights reserved.
 *
 */
#pragma once

//#import <AudioToolbox/AudioToolbox.h>
#include <iostream>
#include <string>
using namespace std;

string documentsDirectory;
char dataString[ 1024 ];
char readByte[ 2 ];

//  The function:
//void vibrate( void ) {
//	AudioServicesPlaySystemSound( kSystemSoundID_Vibrate );
//}

int iOSPointerX = 0;
int iOSPointerY = 0;

//============================================================================================================================
NSString *convertStringToNSString( const std::string& stringToConvert ) {
	return [NSString stringWithUTF8String: stringToConvert.c_str() ];	
}

//============================================================================================================================
string convertNSStringToString( NSString *stringToConvert ) {
	//get the documents path
	const char *convertString = [stringToConvert UTF8String];
	string test;
	
	test.assign( convertString );
	
	return( test );
}

//============================================================================================================================
NSString *ResourcePath( NSString *RequiredFile ) {
	//should return the path to a given resource
	NSString *myImagePath = [[ [NSBundle mainBundle] resourcePath] stringByAppendingString:RequiredFile];
	
	return( myImagePath );
}

//============================================================================================================================
NSString *iPhoneFilename( const std::string& filename ) {
	//returns the iphone location of a particular file in the bundle
	string iPhoneFilename = "/";
	iPhoneFilename.append( filename );
	NSString *NSfilename= ResourcePath( convertStringToNSString( iPhoneFilename.c_str() ) );
	
	return( NSfilename );
}

//============================================================================================================================
void setupApplicationPath( void ) {
	//get the documents path
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *docsDirectory = [paths objectAtIndex:0];
	documentsDirectory = convertNSStringToString( docsDirectory );
}

//============================================================================================================================
NSData *readDataFromBundle( NSString *filename ) {
	NSData *myText = [[[ NSData alloc ] initWithContentsOfFile:filename ] autorelease ];
	if (myText) {
		return( myText );
	}
	
	cout << "ReadDataFromBundle: Failed to open file:" << convertNSStringToString( filename ) << endl;
	exit( 1 );
	return( NULL );
}

//============================================================================================================================
NSString *readFileFromBundle( NSString *filename ) {
	NSString *myText = [[[ NSString alloc ] initWithContentsOfFile:filename ] autorelease ];
	if (myText) {
		return( myText );
	}
	
	cout << "ReadFileFromBundle: Failed to open file:" << convertNSStringToString( filename ) << endl;
	exit( 1 );
	return( NULL );
}

//============================================================================================================================
string readBundleString( const char *stringToExtract, long lineToGet ) {
	int		currentStringCount = 0;
	string  temp;
	
	strcpy( dataString, "" );
	readByte[ 1 ] = 0;
	
	for ( int sp=0; sp<strlen( stringToExtract )-1; sp++ ) {
		readByte[ 0 ] = stringToExtract[ sp ];
        
		switch ( readByte[ 0 ] ) {
			case 10: if ( currentStringCount == lineToGet ) {
				temp.assign( dataString );
				return( temp );
			} else {
				strcpy( dataString, "" );
				currentStringCount ++;
			}break;
			default: strcat( dataString, readByte ); break;
		}
	}
	
	return ( NULL );
}

//============================================================================================================================
string iOSGetAppPath(const std::string& filename)
{
    return convertNSStringToString(iPhoneFilename(filename));
}

std::string GetiOSFilePath(const std::string& filename)
{
	//get the resource location of the filename in the iOS app bundle (mainBundle means the main bundle of the app)
	NSString *Resource = [[ [ NSBundle mainBundle] resourcePath] stringByAppendingString:[NSString stringWithUTF8String: filename.c_str() ] ];
	string returnString;
    
	//convert to a string for returning from the function
	returnString.assign( [Resource UTF8String] );
	return( returnString );
}
