#import "AppDelegate.h"

#import "NSString+validXMLString.h"

@implementation AppDelegate

- (NSString *)filePath {
    return [[filePath retain] autorelease];
}

- (void)setFilePath:(NSString *)value {
    if (filePath != value) {
        [filePath release];
        filePath = [value copy];
    }
}

- (IBAction) doImport: (id) sender
{
	NSArray * rows = [dataSource getRows];
	
	NSXMLElement * root = [[NSXMLElement alloc] initWithName:@"importedData"];
	NSXMLDocument * xml = [[NSXMLDocument alloc] initWithRootElement:root];
	[xml setCharacterEncoding:@"UTF-8"];
	
	NSXMLElement * collection = [[NSXMLElement alloc] initWithName:@"List"];
	[collection addAttribute:[NSXMLNode attributeWithName:@"name" stringValue:@"Tab-Delimited Text"]];

	NSUInteger i = 0;
	for (i = 0; i < [rows count]; i++)
	{
		NSXMLElement * book = [[NSXMLElement alloc] initWithName:@"Book"];

		NSDictionary * entry = [rows objectAtIndex:i];
		
		NSArray * keys = [entry allKeys];
		
		NSUInteger j = 0;
		for (j = 0; j < [keys count]; j++)
		{
			NSObject * key = [keys objectAtIndex:j];

			NSObject * value = [entry objectForKey:key];
			
			if (value != nil)
			{
				NSXMLElement * field = [[NSXMLElement alloc] initWithName:@"field"];

				[field addAttribute:[NSXMLNode attributeWithName:@"name" stringValue:[key description]]];
				[field setStringValue:[[value description] validXMLString]];
				
				[book addChild:field];
			}
		}
		
		[collection addChild:book];
	}

	[root addChild:collection];

#if 0
	NSData *xmlData = [xml XMLDataWithOptions:NSXMLNodePrettyPrint];
#else
	NSData *xmlData = [xml XMLData];
#endif
	
	const char * utfData = [xmlData bytes];
	
	fprintf (stdout, "%s", utfData);
	fflush (stdout);
	
	[NSApp terminate:self];
}

- (void) awakeFromNib
{
	[NSApp activateIgnoringOtherApps:YES];
}

- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename
{
	[self setFilePath:filename];
}

- (void) applicationDidFinishLaunching: (NSNotification *) aNotification
{
	if ([self filePath] == nil) {
		NSOpenPanel * fileOpen = [NSOpenPanel openPanel];
		
		NSInteger results = [fileOpen runModalForTypes:[NSArray arrayWithObject:@"txt"]];
		
		if (results == NSCancelButton)
		{
			[[NSApplication sharedApplication] terminate:nil];
			
			return;
		}
		
		[self setFilePath:[[fileOpen filenames] objectAtIndex:0]];
	}
	
	NSMutableString * fileContents = [NSMutableString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];

	if (fileContents == nil)
	{
		NSLog (@"mac roman");
		fileContents = [NSMutableString stringWithContentsOfFile:filePath encoding:NSMacOSRomanStringEncoding error:NULL];

		if (fileContents == nil)
		{
			NSLog (@"ascii");
			fileContents = [NSMutableString stringWithContentsOfFile:filePath encoding:NSASCIIStringEncoding error:NULL];

			if (fileContents == nil)
			{
		        NSRunAlertPanel (@"Error", @"Unable to determine file encoding. Check that your file is saved as a UTF-8, MacRoman, or ASCII document.", @"Quit", nil, nil);

				[NSApp terminate:self];
			}
		}
	}
	
	// NSLog (@"file contents = --%@--", fileContents);
	
	dataSource = [[TableDataSource alloc] init];
	
	[dataSource setStringContents:fileContents];
	
	NSArray *columnHeaders = [dataSource columnHeaders];

	NSUInteger columnCount = [dataSource getColumnCount];
	
	NSUInteger i = 0;
	
	for (i = 0; i < columnCount; i++)
	{
		NSNumber * index = [NSNumber numberWithUnsignedInteger:i];
		
		NSString *columnName;
		if (columnHeaders == nil) {
			columnName = [index description];
		}
		else {
			columnName = [columnHeaders objectAtIndex:i];
		}
		
		NSTableColumn * column = [[NSTableColumn alloc] initWithIdentifier:columnName];
		[[column headerCell] setStringValue:columnName];
		[column setEditable:NO];
		[[column dataCell] setFont:[NSFont systemFontOfSize:11]];
		
		[table addTableColumn:column];
	}
	
	[table setDataSource:dataSource];
	[table setDelegate:self];
	
	[fieldName setDelegate:self];
	
	[window makeKeyAndOrderFront:nil];
}

- (void) tableViewSelectionDidChange: (NSNotification *) aNotification
{
	if ([table selectedColumn] != -1)
	{
		NSTableColumn * column = [[table tableColumns] objectAtIndex:[table selectedColumn]];
		
		[fieldName setStringValue:[[column identifier] description]];
		[fieldName setEnabled:YES];
	}
	else
	{
		[fieldName setEnabled:NO];
		[fieldName setStringValue:@""];
	}
}

- (void) comboBoxSelectionDidChange: (NSNotification *) notification
{
	[fieldName setStringValue:[[fieldName objectValueOfSelectedItem] description]];
	
	[self controlTextDidChange:notification];
}

- (void) controlTextDidChange: (NSNotification *) aNotification
{
	NSArray * columns = [table tableColumns];

	NSString * newName = [fieldName stringValue];
	
	if (newName == nil || [[newName description] isEqualToString:@""])
		return;
		
	NSTableColumn * column = [columns objectAtIndex:[table selectedColumn]];

	NSUInteger count = 0;
	
	NSUInteger i = 0;
	for (i = 0; i < [columns count]; i++)
	{
		NSTableColumn * oldColumn = [columns objectAtIndex:i];
		
		if (oldColumn != column && [[[oldColumn identifier] description] isEqualToString:newName])
			count++;
	}

	if (count > 0)
	{
		NSRunAlertPanel(@"Duplicate field name", @"A column with this field name already exists. Please choose another.", @"OK", nil, nil);

		[fieldName setStringValue:[[column identifier] description]];
			
		return;
	}

	[dataSource replaceKey:[column identifier] withKey:newName];
	[column setIdentifier:newName];
	[[column headerCell] setStringValue:newName];
	
	[table reloadData];
}

- (void) windowWillClose: (NSNotification *) aNotification
{
	[NSApp terminate:self];
}

@end
