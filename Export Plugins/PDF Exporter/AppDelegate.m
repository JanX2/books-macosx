#import "AppDelegate.h"
#import "Book.h"

@implementation AppDelegate

- (IBAction)createPDF:(id)sender
{
	[self exportPDF:sender];

	NSSavePanel * panel = [NSSavePanel savePanel];
	[panel setRequiredFileType:@"pdf"];
	
	int choice = [panel runModal];

	if (choice == NSFileHandlingPanelOKButton)
	{
		NSString * filename = [panel filename];
		
		[[NSFileManager defaultManager] copyPath:@"/tmp/books-export/export.pdf" toPath:filename handler:nil];
	}
}	

- (IBAction)exportPDF:(id)sender
{
	[progressIndicator startAnimation:self];
	
	[NSApp beginSheet:progressWindow modalForWindow:mainWindow modalDelegate:self didEndSelector:nil contextInfo:NULL];
	
	NSArray * books = [selectedRecordsController arrangedObjects];
	
	NSXMLElement * root = [[NSXMLElement alloc] initWithName:@"exportData"];
	NSXMLDocument * xml = [[NSXMLDocument alloc] initWithRootElement:root];
	
	int i = 0;
	for (i = 0; i < [books count]; i++)
	{
		NSXMLElement * book = [[NSXMLElement alloc] initWithName:@"Book"];

		Book * entry = [books objectAtIndex:i];
		
		NSArray * keys = [entry allKeys];
		
		int j = 0;
		for (j = 0; j < [keys count]; j++)
		{
			NSString * key = [keys objectAtIndex:j];

			NSObject * value = [entry valueForKey:key];
			
			if (value != nil)
			{
				NSXMLElement * field = [[NSXMLElement alloc] initWithName:@"field"];

				[field addAttribute:[NSXMLNode attributeWithName:@"name" stringValue:[key description]]];
				[field setStringValue:[value description]];
				
				[book addChild:field];
			}
		}
		
		[root addChild:book];
	}

	NSString * xmlString = [xml description];

	[xmlString writeToFile:@"/tmp/books-export/export.xml" atomically:YES encoding:NSUTF8StringEncoding error:NULL];
	
	NSString * selectedStyle = (NSString *) [styleList titleOfSelectedItem];
	
	NSString * resourcePath = [[NSBundle mainBundle] resourcePath];
	
	NSTask * task = [[NSTask alloc] init];
	
	[task setCurrentDirectoryPath:resourcePath];
	[task setLaunchPath:[[NSBundle mainBundle] pathForResource:@"run" ofType:@"sh"]];
	
	NSMutableArray * arguments  = [NSMutableArray array];
	[arguments addObject:[stylesTable valueForKey:selectedStyle]];
	[arguments addObject:@"/tmp/books-export/export.xml"];
	[arguments addObject:@"/tmp/books-export/export.pdf"];

	[task setArguments:arguments];
	
	[task launch];
	[task waitUntilExit];
	
	[task release];
	
	[NSApp endSheet:progressWindow];
	[progressWindow orderOut:self];
	
	[progressIndicator stopAnimation:self];
}

- (IBAction)customizeFields:(id)sender
{
	[panelWindow makeKeyAndOrderFront:self];
}

- (IBAction)doneSelectingFields:(id)sender
{
	[panelWindow orderOut:self];
}

- (IBAction)previewRecords:(id)sender
{
	[self exportPDF:sender];

	[NSTask launchedTaskWithLaunchPath:@"/usr/bin/open" arguments:[NSArray arrayWithObject:@"/tmp/books-export/export.pdf"]];
}

- (IBAction)removeRecords:(id)sender
{
	[selectedRecordsController removeObjects:[selectedRecordsController selectedObjects]];
}

- (IBAction)selectRecords:(id)sender
{
	[selectedRecordsController addObjects:[allRecordsController selectedObjects]];
}

- (NSArray *) getPrintStyles
{
	stylesTable = [[NSMutableDictionary alloc] init];
	
	NSString * appSupport = @"Library/Application Support/Books/Plugins/PDF Styles/";
	NSString * appPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/Contents/Resources/"];
	
	NSString * userPath = [NSHomeDirectory () stringByAppendingPathComponent:appSupport];
	NSString * sysPath = [@"/" stringByAppendingPathComponent:appSupport];

	NSArray * paths = [NSArray arrayWithObjects:appPath, sysPath, userPath, nil];

	NSEnumerator * pathEnum = [paths objectEnumerator];
	
	NSString * path;
 
	while (path = [pathEnum nextObject])
	{
		NSEnumerator * e = [[[NSFileManager defaultManager] directoryContentsAtPath:path] objectEnumerator];

		NSString * name;

		while (name = [e nextObject])
		{
			if ([[name pathExtension] isEqualToString:@"xsl"])
				[stylesTable setValue:[path stringByAppendingPathComponent:name] forKey:[name stringByDeletingPathExtension]];
		}
	}

	return [[stylesTable allKeys] retain];
}

- (void) setPrintStyles: (NSArray *) styles
{
}

- (void)windowWillClose:(NSNotification *)aNotification
{
	[NSApp terminate:self];
}

- (void) awakeFromNib
{
	[NSApp activateIgnoringOtherApps:YES];
	
	NSArray * columns = [allRecordsTable tableColumns];
	
	int i = 0;
	for (i = 0; i < [columns count]; i++)
	{
		NSTableColumn * column = [columns objectAtIndex:i];
		
		[[column dataCell] setFont:[NSFont systemFontOfSize:11]];
	}

	columns = [selectedRecordsTable tableColumns];
	
	for (i = 0; i < [columns count]; i++)
	{
		NSTableColumn * column = [columns objectAtIndex:i];
		
		[[column dataCell] setFont:[NSFont systemFontOfSize:11]];
	}

	NSError * error;
	
	NSURL * url = [NSURL URLWithString:@"file:///tmp/books-export/books-export.xml"];
	
	NSXMLDocument * xml = [[NSXMLDocument alloc] initWithContentsOfURL:url options:NSXMLDocumentTidyXML error:&error];

	if (xml != nil)
	{
		NSArray * books = [[xml rootElement] elementsForName:@"Book"];
		
		for (i = 0; i < [books count]; i++)
		{
			NSXMLElement * book = [books objectAtIndex:i];
			NSArray * fields = [book elementsForName:@"field"];

			Book * bookObject = [[Book alloc] init];

			int j = 0;
			for (j = 0; j < [fields count]; j++)
			{
				NSXMLElement * field = [fields objectAtIndex:j];
				
				NSString * key = [[field attributeForName:@"name"] stringValue];
				NSString * value = [field stringValue];
				
				[bookObject setValue:value forKey:key];
			}
			
			[allRecordsController addObject:bookObject];
		}
	}
	else
	{
        NSRunAlertPanel (@"Error", @"Unable to locate book data. Check your Books installation.", @"Quit", nil, nil);
		
		[NSApp terminate:self];
	}
}

@end
