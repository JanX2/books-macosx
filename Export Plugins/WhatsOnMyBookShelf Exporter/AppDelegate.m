#import "AppDelegate.h"

#include <CoreFoundation/CoreFoundation.h>
#include <Security/Security.h>
#include <CoreServices/CoreServices.h>

@implementation AppDelegate

- (NSString *) getPasswordString
{
	NSString * usernameString = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
	
	if (usernameString == nil)
		return nil;
		
	const char * userData = [usernameString cStringUsingEncoding:NSASCIIStringEncoding];
	UInt32 uLength = strlen (userData);

	void * passwordData = nil;
	UInt32 pLength = nil;

	OSStatus status;

	status = SecKeychainFindGenericPassword (
		NULL,															// default keychain
		27,																// length of service name
		"WhatsOnMyBookshelf Exporter",									// service name
		uLength,														// length of account name
		userData,														// account name
		&pLength,														// length of password
		&passwordData,													// pointer to password data
		NULL															// the item reference
    );

	if (status == noErr)
	{
		NSString * passwordString = [NSString stringWithCString:passwordData encoding:NSASCIIStringEncoding];
		return [passwordString retain];
	}

	return nil;
}

- (void) setPasswordString: (NSString *) passwordString
{
	NSString * usernameString = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];

	const char * userData = [usernameString cStringUsingEncoding:NSASCIIStringEncoding];
	UInt32 uLength = strlen (userData);

	OSStatus status;

	const char * passwordData = [passwordString cStringUsingEncoding:NSASCIIStringEncoding];
	UInt32 pLength = strlen (passwordData);
	
	if ([self getPasswordString] == nil)
	{
		status = SecKeychainAddGenericPassword (
                NULL,															// default keychain
                27,																// length of service name
                "WhatsOnMyBookshelf Exporter",									// service name
                uLength,														// length of account name
                userData,														// account name
                pLength,														// length of password
                passwordData,													// pointer to password data
                NULL															// the item reference
		);
		
		return;
	}
	else
	{
		SecKeychainItemRef item = nil;
		
		status = SecKeychainFindGenericPassword (
			NULL,															// default keychain
			27,																// length of service name
			"WhatsOnMyBookshelf Exporter",									// service name
			uLength,														// length of account name
			[usernameString cStringUsingEncoding:NSASCIIStringEncoding],		// account name
			NULL,															// length of password
			NULL,															// pointer to password data
			&item															// the item reference
		);

		status = SecKeychainItemDelete (item);

		[self setPasswordString:passwordString];

		if (status == noErr)
			return;
		else
		{
			NSLog (@"Error saving password: %d", status);
			return;
		}
	}
	
}

- (IBAction) myInventory: (id) sender
{
	NSString * usernameString = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
	
	if (usernameString == nil || [usernameString isEqual:@""])
		NSRunAlertPanel (@"No Username Found!", @"Please enter a username in provided field.", @"OK", nil, nil);
	else
	{
		NSString * urlString = [NSString stringWithFormat:@"http://www.whatsonmybookshelf.com/users/%@", usernameString, nil];
		[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:urlString]];
	}
}

- (IBAction)upload:(id)sender
{
	NSString * passwordString = [password stringValue];

	NSString * usernameString = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];

	if (usernameString == nil || [usernameString isEqual:@""])
	{
		NSRunAlertPanel (@"No Username Found!", @"Please enter a username in provided field.", @"OK", nil, nil);
		return;
	}
	
	NSString * tagString = [tags stringValue];
	NSString * commentString = [comments string];
	
	NSArray * books = [tableArray arrangedObjects];
	
	NSMutableString * isbnList = [NSMutableString string];
	
	int i = 0;
	for (i = 0; i < [books count]; i++)
	{
		NSString * isbn = [[books objectAtIndex:i] valueForKey:@"isbn"];
		
		if (isbn != nil)
		{
			[isbnList appendString:isbn];
			[isbnList appendString:@"\n"];
		}
	}
	
	[isbnList writeToFile:@"/tmp/books-export/womb.txt" atomically:YES encoding:NSUTF8StringEncoding error:nil];

	NSBundle * bundle = [NSBundle mainBundle];

	NSString * scriptName = @"womb.py";
	NSString * scriptPath = [bundle pathForResource:[scriptName stringByDeletingPathExtension] 
		ofType:[scriptName pathExtension]];
	
	NSTask * task = [[NSTask alloc] init];
	
	[task setLaunchPath:scriptPath];
	[task setCurrentDirectoryPath:[scriptPath stringByDeletingLastPathComponent]];
	
	NSArray * arguments = [NSArray arrayWithObjects:usernameString, passwordString, tagString, commentString, nil];
	[task setArguments:arguments];
	
	[task launch];
	
	[task waitUntilExit];
	
	if ([task terminationStatus] == 255)
	{
		NSRunAlertPanel (@"Bad Password!", @"Your password is incorrect.", @"OK", nil, nil);
		return;
	}
	else
	{
		NSString * wombError = [NSString stringWithContentsOfFile:@"/tmp/books-export/womb.error" encoding:NSASCIIStringEncoding error:nil];

		if (![wombError isEqualTo:@""])
		{
			[errorText setString:wombError];
			[errorWindow makeKeyAndOrderFront:sender];
		}
	}
}

- (void)windowWillClose: (NSNotification *) aNotification
{
	NSString * passwordString = [password stringValue];
	NSString * keychainPassword = [self getPasswordString];

	if (![keychainPassword isEqualTo:passwordString])
		[self setPasswordString:passwordString];

	[NSApp terminate:nil];
}

- (void) awakeFromNib
{
	NSTableColumn * column = [[tableView tableColumns] objectAtIndex:0];
	
	[[column dataCell] setFont:[NSFont systemFontOfSize:11]];

	NSError * error;
	
	NSURL * url = [NSURL URLWithString:@"file:///tmp/books-export/books-export.xml"];
	
	NSXMLDocument * xml = [[NSXMLDocument alloc] initWithContentsOfURL:url options:NSXMLDocumentTidyXML error:&error];

	if (xml != nil)
	{
		NSArray * books = [[xml rootElement] elementsForName:@"Book"];
		
		int i = 0;
		for (i = 0; i < [books count]; i++)
		{
			NSXMLElement * book = [books objectAtIndex:i];
			NSArray * fields = [book elementsForName:@"field"];

			NSMutableDictionary * bookObject = [NSMutableDictionary dictionary];

			int j = 0;
			for (j = 0; j < [fields count]; j++)
			{
				NSXMLElement * field = [fields objectAtIndex:j];
				
				NSString * key = [[field attributeForName:@"name"] stringValue];
				NSString * value = [field stringValue];
				
				[bookObject setValue:value forKey:key];
			}
			
			if ([bookObject valueForKey:@"isbn"] != nil)
				[tableArray addObject:bookObject];
		}
	}
	else
	{
        NSRunAlertPanel (@"Error", @"Unable to locate book data. Check your Books installation.", @"Quit", nil, nil);
		
		[NSApp terminate:self];
	}

	NSString * passwordString = [self getPasswordString];

	if (passwordString != nil)
		[password setStringValue:passwordString];
}

@end
