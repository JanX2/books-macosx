/* AppDelegate */

#import <Cocoa/Cocoa.h>
#import "TableDataSource.h"

@interface AppDelegate : NSObject
{
    IBOutlet id fieldName;
    IBOutlet id table; 
	IBOutlet id window;
	
	TableDataSource * dataSource;
	
	NSString *filePath;
}

- (NSString *)filePath;
- (void)setFilePath:(NSString *)value;

- (IBAction) doImport: (id) sender;
- (void) tableViewSelectionDidChange: (NSNotification *) aNotification;
- (void) controlTextDidChange: (NSNotification *) aNotification;
- (void) comboBoxSelectionDidChange: (NSNotification *) notification;
- (void) windowWillClose: (NSNotification *) aNotification;

@end
