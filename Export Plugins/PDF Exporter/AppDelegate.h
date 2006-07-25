/* AppDelegate */

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject
{
    IBOutlet id allRecordsStatus;
    IBOutlet id allRecordsTable;
    IBOutlet id mainWindow;
    IBOutlet id panelTable;
    IBOutlet id panelWindow;
    IBOutlet id progressWindow;
    IBOutlet id progressIndicator;
    IBOutlet id searchField;
    IBOutlet id selectedRecordsStatus;
    IBOutlet id selectedRecordsTable;
    IBOutlet id styleList;

    IBOutlet id allRecordsController;
    IBOutlet id selectedRecordsController;
    IBOutlet id fieldsController;
	
	NSMutableDictionary * stylesTable;
}

- (IBAction)createPDF:(id)sender;
- (IBAction)exportPDF:(id)sender;
- (IBAction)customizeFields:(id)sender;
- (IBAction)doneSelectingFields:(id)sender;
- (IBAction)previewRecords:(id)sender;
- (IBAction)removeRecords:(id)sender;
- (IBAction)selectRecords:(id)sender;

- (NSArray *) getPrintStyles;
- (void) setPrintStyles: (NSArray *) styles;

@end
