#ifdef __APPLE__

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

#include "cocoaHelpers.hpp"
#include <SDL2/SDL.h>

const char* getResourcesPath(void)
{
	static char pathStorage[256] = {0};
	
	if (!strlen(pathStorage)) {	
		NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
		NSArray* paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
		NSString* applicationSupportDirectory = [paths objectAtIndex:0];		
		NSString* completeDirectory = [applicationSupportDirectory stringByAppendingString:@"/RSDKv4"];
		
		BOOL isDir;
		// check if the directory actually exists before blindly fucking with it
		NSFileManager* fileManager = [NSFileManager defaultManager];
		if(![fileManager fileExistsAtPath:completeDirectory isDirectory: &isDir]) {
			if(![fileManager createDirectoryAtPath:completeDirectory attributes: nil]) {
				printf("Failed to create directory\n");
			}
		}		
		else {	
			printf("Directory exists\n");
		}
		
		strncpy(pathStorage, [applicationSupportDirectory UTF8String], 256);
		
		[pool release];
	}
	
	return pathStorage;
}

const char* getAppResourcesPath(void)
{
	static char pathStorage[256] = {0};
	
	if (!strlen(pathStorage)) {	
		NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
		NSString *resourceDirectory = [[NSBundle mainBundle] resourcePath];
		
		char* str = (char*)[resourceDirectory UTF8String];	
		strncpy(pathStorage, str, 256);
		
		[pool release];
	}
	
	return pathStorage;
}

bool pickRSDKFile() {
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	NSArray* fileTypes = [[NSArray alloc] initWithObjects: @"rsdk", nil];
	
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);	
	NSString* completePath = [[paths objectAtIndex:0] stringByAppendingString:@"/RSDKv4/Data.rsdk"];
	
	NSOpenPanel* dialog = [NSOpenPanel openPanel];
	[dialog setAllowsMultipleSelection: NO];
	[dialog setAllowedFileTypes: fileTypes];
	[dialog setTitle: @"Please pick a compatible RSDK datapack"];
	[dialog setPrompt: @"Import Datapack"];
	
	auto response = [dialog runModal];
	
	if (response == 1) {
		if ([[NSFileManager defaultManager] respondsToSelector: @selector(copyItemAtPath:toPath:error:)]) {		
			NSError* error = nil;
			if ([[NSFileManager defaultManager] copyItemAtPath: [[dialog URL] path] toPath: completePath error: &error]) {
				[pool release];
				return TRUE;			
			}
			else {
				printf("error: %s\n", [[error localizedDescription] UTF8String]);
				[pool release];
				return FALSE;
			}
		}
		else {
			if ([[NSFileManager defaultManager] copyPath: [[dialog URL] path] toPath: completePath handler: nil]) {
				[pool release];
				return TRUE;			
			}
			else {
				printf("couldn't copy file, no idea why :D\n");
				[pool release];
				return FALSE;
			}
			
		}
	}
	
	[pool release];
	return FALSE;
}

void showMissingRSDKMessage(void) {
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);	
	NSString* completeDirectory = [[paths objectAtIndex:0] stringByAppendingString:@"/RSDKv4"];
	
	NSString* informative = [NSString stringWithFormat: @"The engine could not find a compatible datapack. Please copy a \"Data.rsdk\" file to \"%@\"", completeDirectory];
	
	NSAlert* alert = [[NSAlert alloc] init];
	[alert setMessageText: @"Missing Game!"];
	[alert setInformativeText: informative]; 
	[alert addButtonWithTitle: @"OK"];
	[alert setAlertStyle: NSCriticalAlertStyle];
	
	[alert runModal];
	
	[pool release];
}

int main(int argc, char** argv) {	
	NSAutoreleasePool* pool = [NSAutoreleasePool new];	
	[NSApplication sharedApplication];
	
	SDL_Init(SDL_INIT_EVERYTHING);
	SDL_main(argc, argv);
}


#endif