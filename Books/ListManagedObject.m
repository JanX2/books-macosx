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


#import "ListManagedObject.h"
#import "BooksAppDelegate.h"
#import "ListNameString.h"

@implementation ListManagedObject

- (NSData *) getIcon
{
	if (iconData == nil)
		iconData = [[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"list-small" ofType:@"png"]] retain];

	return iconData;	
}

- (void) setIcon: (NSData *) icon
{

}

- (NSArray *) getBooks
{
	return [[self valueForKey:@"items"] allObjects];
}

- (NSScriptObjectSpecifier *) objectSpecifier
{
	BooksAppDelegate * delegate = [[NSApplication sharedApplication] delegate];
	
	NSIndexSpecifier * specifier = [[NSIndexSpecifier alloc] 
										initWithContainerClassDescription:[NSScriptClassDescription classDescriptionForClass:[delegate class]] 
										containerSpecifier:[delegate objectSpecifier]
										key:@"booklists"];
	
	return specifier;
}

- (BOOL) getCanAdd
{
	return YES;
}

- (void) setCanAdd: (BOOL) canAdd
{

}

/* - (NSString *) getName
{
	return [ListNameString stringWithString:[self primitiveValueForKey:@"name"]];
}*/

- (NSString *) getSortName
{
	return [@"0 " stringByAppendingString:[self valueForKey:@"name"]];
}

- (void) setSortName: (NSString *) name
{

}


@end
