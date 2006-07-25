//
//  AppDelegate.m
//  Pilot-DB Exporter
//
//  Created by Chris Karr on 7/24/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

-(void) awakeFromNib
{
	NSBundle * bundle = [NSBundle mainBundle];
	
	NSSavePanel * panel = [NSSavePanel savePanel];
	
	[panel setAccessoryView:accessoryView];
	[panel setRequiredFileType:@"pdb"];
	int results = [panel runModal];

	if (results == NSCancelButton)
	{
		[[NSApplication sharedApplication] terminate:nil];
		
		return;
	}
		
	NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
	
	NSString * format = [defaults stringForKey:@"Database Format"];
	
	if (format == nil)
		format = @"Pilot-DB (Default)";

	[defaults setValue:format forKey:@"Database Format"];
		
	NSString * title = [defaults stringForKey:@"Database Title"];

	if (title == nil)
		title = @"My Books";

	[defaults setValue:title forKey:@"Database Title"];
	
	NSString * filePath = [panel filename];
	
	NSLog (@"%@ - %@ - %@", filePath, title, format);

	NSString * scriptPath = [bundle pathForResource:@"run" ofType:@"sh"];

	NSTask * task = [[NSTask alloc] init];
	[task setLaunchPath:scriptPath];
	[task setCurrentDirectoryPath:[scriptPath stringByDeletingLastPathComponent]];
	
	NSArray * arguments = [NSArray arrayWithObjects:title, format, filePath, nil];
	[task setArguments:arguments];
	
	[task launch];
	[task waitUntilExit];
	
	[[NSApplication sharedApplication] terminate:nil];
}

@end
