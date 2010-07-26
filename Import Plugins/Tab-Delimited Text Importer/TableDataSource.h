//
//  TableDataSource.h
//  Tab-Delimited Text Importer
//
//  Created by Chris Karr on 3/22/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TableDataSource : NSObject <NSComboBoxDataSource>
{
	NSMutableArray * rows;
	NSMutableDictionary * mapping;
	
	NSArray *columnHeaders;
	NSArray *columnKeys;
	
	NSUInteger count;
}

- (NSArray *)columnHeaders;

- (void) setStringContents: (NSString *) contents;
- (NSUInteger) getColumnCount;

- (NSArray *)columnKeys;
- (void)setColumnKeys:(NSArray *)value;

- (NSInteger) numberOfRowsInTableView: (NSTableView *) aTableView;
- (id) tableView: (NSTableView *) aTableView objectValueForTableColumn: (NSTableColumn *) aTableColumn row: (NSInteger) rowIndex;

- (void) replaceKey: (NSObject *) oldKey withKey:(NSObject *) newKey;
- (NSArray *) getRows;

@end
