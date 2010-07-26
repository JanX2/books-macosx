//
//  TableDataSource.m
//  Tab-Delimited Text Importer
//
//  Created by Chris Karr on 3/22/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "TableDataSource.h"

#import "NSString+validKeyString.h"

@implementation TableDataSource

- (NSArray *)columnHeaders {
    return [[columnHeaders retain] autorelease];
}

- (void)setColumnHeaders:(NSArray *)value {
    if (columnHeaders != value) {
        [columnHeaders release];
        columnHeaders = [value copy];
    }
}

- (NSArray *)columnKeys {
    return [[columnKeys retain] autorelease];
}

- (void)setColumnKeys:(NSArray *)value {
    if (columnKeys != value) {
        [columnKeys release];
        columnKeys = [value copy];
    }
}

- (void) setStringContents: (NSString *) contents
{
	count = 0;
	
	rows = [[NSMutableArray alloc] init];
	
	NSMutableString * tabString = [NSMutableString stringWithString:contents];
	
	[tabString replaceOccurrencesOfString:@"\r\n" withString:@"\n" options:NSCaseInsensitiveSearch range:NSMakeRange (0, [tabString length])];
	[tabString replaceOccurrencesOfString:@"\r" withString:@"\n" options:NSCaseInsensitiveSearch range:NSMakeRange (0, [tabString length])];

	NSArray * lines = [tabString componentsSeparatedByString:@"\n"];
	
	NSUInteger linesCount = [lines count];
	NSUInteger firstValidLine;

	if ((linesCount > 3) 
		&& ![[lines objectAtIndex:0] isEqualToString:@""] 
		&& [[lines objectAtIndex:1] isEqualToString:@""]) {
		
		// This table has header info
		NSArray *rawColumnNames = [[[lines objectAtIndex:0] componentsSeparatedByString:@"\t"] mutableCopy];
		[self setColumnHeaders:rawColumnNames];		
		
		NSMutableArray *columnNames = [NSMutableArray arrayWithCapacity:[rawColumnNames count]];
		
		for (NSString *columnName in rawColumnNames) {
			[columnNames addObject:[columnName validKeyString]];
		}
		
		[self setColumnKeys:columnNames];		
		
		firstValidLine = 2;
	}
	else {
		firstValidLine = 0;
	}
	
	for (NSUInteger i = firstValidLine; i < linesCount; i++)
	{
		NSString * line = [lines objectAtIndex:i];
		
		NSMutableDictionary * row = [NSMutableDictionary dictionary];
		
		NSArray * columns = [line componentsSeparatedByString:@"\t"];
		
		for (NSUInteger j = 0; j < [columns count]; j++)
		{
			NSString * column = (NSString *) [columns objectAtIndex:j];

			NSString *columnName;
			if (columnKeys == nil) {
				NSNumber *index = [NSNumber numberWithUnsignedInteger:j];
				columnName = [index description];
			}
			else {
				columnName = [columnKeys objectAtIndex:j];
			}
			
			if (column != nil && ![column isEqualToString:@""])
				[row setObject:[columns objectAtIndex:j] forKey:columnName];
			
			if (count < (j + 1))
				count = j + 1;
		}
		
		if ([[row allKeys] count] > 0)
			[rows addObject:row];
	}
	
	mapping = [[NSMutableDictionary alloc] init];
	
	[mapping setValue:@"title" forKey:@"Title"];
	[mapping setValue:@"series" forKey:@"Series"];
	[mapping setValue:@"genre" forKey:@"Genre"];
	[mapping setValue:@"authors" forKey:@"Authors"];
	[mapping setValue:@"editors" forKey:@"Editors"];
	[mapping setValue:@"illustrators" forKey:@"Illustrators"];
	[mapping setValue:@"translators" forKey:@"Translators"];
	[mapping setValue:@"publisher" forKey:@"Publisher"];
	[mapping setValue:@"publishDate" forKey:@"Publish Date"];
	[mapping setValue:@"isbn" forKey:@"ISBN"];
	[mapping setValue:@"keywords" forKey:@"Keywords"];
	[mapping setValue:@"format" forKey:@"Format"];
	[mapping setValue:@"edition" forKey:@"Edition"];
	[mapping setValue:@"publishPlace" forKey:@"Publish Place"];
	[mapping setValue:@"length" forKey:@"Length"];
}

- (NSUInteger) getColumnCount
{
	return count;
}

- (NSInteger) numberOfRowsInTableView: (NSTableView *) aTableView
{
	return [rows count];
}

- (id) tableView: (NSTableView *) aTableView objectValueForTableColumn: (NSTableColumn *) aTableColumn row: (NSInteger) rowIndex
{
	NSDictionary * entry = [rows objectAtIndex:rowIndex];
	
	NSString * column = [[aTableColumn identifier] description];

	NSString * mapKey = [mapping objectForKey:column];
	
	if (mapKey != nil)
		column = mapKey;
	
	return [entry objectForKey:column];
}

- (void) replaceKey: (NSObject *) oldKey withKey:(NSObject *) newKey
{
	if ([oldKey isEqual:newKey])
		return;
		
	NSInteger i = 0;

	NSString * mapKey = [mapping objectForKey:newKey];
	
	if (mapKey != nil)
		newKey = mapKey;

	for (i = 0; i < [rows count]; i++)
	{
		NSMutableDictionary * entry = [rows objectAtIndex:i];

		NSObject * value = [entry objectForKey:oldKey];
		
		if (value != nil)
		{
			[entry setObject:value forKey:newKey];
			[entry removeObjectForKey:oldKey];
		}
	}
}

- (NSArray *) getRows
{
	return rows;
}

@end
