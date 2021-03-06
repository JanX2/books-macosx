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


#import "BookListArrayController.h"
#import "SmartListManagedObject.h"
#import "BookManagedObject.h"

@implementation BookListArrayController

- (int) numberOfRowsInTableView: (NSTableView *) aTableView
{
	return [[self arrangedObjects] count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
	BookManagedObject * book = [[self arrangedObjects] objectAtIndex:rowIndex];

	return [book valueForKey:[aTableColumn identifier]];
}

- (BOOL)tableView:(NSTableView *)tv writeRowsWithIndexes:(NSIndexSet *)rows toPasteboard:(NSPasteboard*)pboard
{
	if ([[listController selectedObjects] count] != 1)
		return NO;

	NSArray * objects = [[self arrangedObjects] objectsAtIndexes:rows];
	
	NSString * type = @"Books Book Type";
    NSArray * types = [NSArray arrayWithObjects:type, nil];
	
	[pboard declareTypes:types owner:self];

	NSMutableArray * urls = [NSMutableArray array];    
	
	int i = 0;
	for (i = 0; i < [objects count]; i++)
	{
		BookManagedObject * book = [objects objectAtIndex:i];
		
		NSURL * url = [[book objectID] URIRepresentation];
		[urls addObject:[url description]];
	}

	[pboard setData:[NSArchiver archivedDataWithRootObject:urls] forType:type];
	
    return YES;
}

- (void) addObjects: (NSArray *) objects
{
	[super addObjects:objects];
}

/* - (void) pasteboard:(NSPasteboard *) pboard provideDataForType:(NSString *) type
{
	if ([type isEqualTo:@"Books Book Type"])
	{
		NSMutableArray * rowCopies = [NSMutableArray array];    

		unsigned int index = 0;

		while (NSNotFound != (index = [selectedRows indexGreaterThanOrEqualToIndex:index]))
		{
			NSURL * url = [[[[self arrangedObjects] objectAtIndex:index] objectID] URIRepresentation];
			
			[rowCopies addObject:[url description]];
			
			index++;
		}

		[pboard setPropertyList:rowCopies forType:type];
	}
} */

- (NSDragOperation)tableView:(NSTableView *)tableView validateDrop:(id <NSDraggingInfo>)info proposedRow:(int)row proposedDropOperation:(NSTableViewDropOperation)operation
{
	return NSDragOperationMove;
}

- (void) dealloc
{
	if (selectedRows != nil)
		[selectedRows release];
	
	[super dealloc];
}

@end
