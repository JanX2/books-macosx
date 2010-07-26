#import <Foundation/Foundation.h>
#import "Search.h"

int main (int argc, const char * argv[]) 
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

	if (argc > 2)
		[Search searchForXml:[[[NSProcessInfo processInfo] arguments] objectAtIndex:1] locale:[[[NSProcessInfo processInfo] arguments] objectAtIndex:2]];
	else 
		[Search searchForXml:@"/tmp/books-quickfill.xml" locale:@"us"];
		
    [pool drain];
    return 0;
}
