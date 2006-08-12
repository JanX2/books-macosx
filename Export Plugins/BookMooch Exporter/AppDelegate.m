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

	NSLog (@"ul %d %s", uLength, userData);
	
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
		NSLog (@"error saving password %d", status);
		
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

- (IBAction)removeBook:(id)sender
{
	NSLog (@"Remove Book");
}

- (IBAction)upload:(id)sender
{
	NSString * keychainPassword = [self getPasswordString];
	NSString * passwordString = [password stringValue];

	if (![keychainPassword isEqualTo:passwordString])
		[self setPasswordString:passwordString];
	
	NSLog (@"Upload - %@", passwordString);
}

- (void)windowWillClose: (NSNotification *) aNotification
{
	[NSApp terminate:nil];
}

- (void) awakeFromNib
{
	NSString * passwordString = [self getPasswordString];

	if (passwordString != nil)
		[password setStringValue:passwordString];
}

@end
