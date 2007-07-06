/*
   Copyright (c) 2006 Chris J. Karr

   Permission is hereby granted, free of charge, to any person 
   obtaining a copy of this software and associated documentation 
   files (the "Software"), to deal in the Software without restriction, 
   including without limitation the rights to use, copy, modify, merge, 
   publish, distribute, sublicense, and/or sell copies of the Software, 
   and to permit persons to whom the Software is furnished to do so, 
   subject to the following conditions:

   The above copyright notice and this permission notice shall be 
   included in all copies or substantial portions of the Software.

   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
   EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
   MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND 
   NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS 
   BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN 
   ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN 
   CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
   SOFTWARE.
*/


#import "BooksCreateNewSmartListCommand.h"
#import "BooksAppDelegate.h"
#import "SmartListManagedObject.h"

@implementation BooksCreateNewSmartListCommand

- (id) performDefaultImplementation
{
	NSDictionary * args = [self evaluatedArguments];
	NSLog (@"eval args %@", args);
	
	NSString * listName = nil;
	
	if ([args objectForKey:@"called"] != nil)
		listName = [args objectForKey:@"called"];

	SmartListManagedObject * obj = [(BooksAppDelegate *) [[NSApplication sharedApplication] delegate] 
								asCreateNewSmartList:listName];

	if ([args objectForKey:@"withrules"] != nil)
	{
		NSString * rules = [args objectForKey:@"withrules"];
		
		[obj setPredicate:[NSPredicate predicateWithFormat:rules]];
	}

	return obj;
}

@end
