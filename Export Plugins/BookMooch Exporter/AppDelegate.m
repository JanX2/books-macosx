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
		
	const char * userData = [usernameString cStringUsingEncoding:NSUTF8StringEncoding];
	UInt32 uLength = strlen (userData);

	void * passwordData = nil;
	UInt32 pLength = nil;

	OSStatus status;

	status = SecKeychainFindGenericPassword (
		NULL,															// default keychain
		18,																// length of service name
		"BookMooch Exporter",											// service name
		uLength,														// length of account name
		userData,														// account name
		&pLength,														// length of password
		&passwordData,													// pointer to password data
		NULL															// the item reference
    );

	if (status == noErr)
	{
		NSString * passwordString = [NSString stringWithCString:passwordData encoding:NSUTF8StringEncoding];
		return passwordString;
	}
	
	return nil;
}

- (void) setPasswordString: (NSString *) passwordString
{
	NSString * usernameString = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];

	const char * userData = [usernameString cStringUsingEncoding:NSUTF8StringEncoding];
	UInt32 uLength = strlen (userData);

	OSStatus status;

	const char * passwordData = [passwordString cStringUsingEncoding:NSUTF8StringEncoding];
	UInt32 pLength = strlen (passwordData);
	
	if ([self getPasswordString] == nil)
	{
		status = SecKeychainAddGenericPassword (
                NULL,															// default keychain
                18,																// length of service name
                "BookMooch Exporter",											// service name
                uLength,														// length of account name
                userData,														// account name
                pLength,														// length of password
                passwordData,													// pointer to password data
                NULL															// the item reference
		);
	}
	else
	{
		SecKeychainItemRef item = nil;
		
		status = SecKeychainFindGenericPassword (
			NULL,															// default keychain
			18,																// length of service name
			"BookMooch Exporter",											// service name
			uLength,														// length of account name
			[usernameString cStringUsingEncoding:NSUTF8StringEncoding],		// account name
			NULL,															// length of password
			NULL,															// pointer to password data
			&item															// the item reference
		);

		status = SecKeychainItemDelete (item);
		
		[self setPasswordString:passwordString];
	}
	
	if (status == noErr)
		return;
	else
	{
		NSLog (@"Error saving password: %d", status);
		return;
	}
}

- (IBAction) myInventory: (id) sender
{
	NSString * usernameString = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
	
	if (usernameString == nil || [usernameString isEqual:@""])
		NSRunAlertPanel (@"No Username Found!", @"Please enter a username in provided field.", @"OK", nil, nil);
	else
	{
		NSString * urlString = [NSString stringWithFormat:@"http://www.bookmooch.com/m/inventory/%@", usernameString, nil];
		[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:urlString]];
	}
}

- (IBAction)upload:(id)sender
{
	NSString * keychainPassword = [self getPasswordString];
	NSString * passwordString = [password stringValue];

	if (![keychainPassword isEqualTo:passwordString])
		[self setPasswordString:passwordString];
	
	NSLog (@"Upload");
}

- (void)windowWillClose: (NSNotification *) aNotification
{
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
