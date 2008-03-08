#import <Foundation/Foundation.h>
#import "Search.h"

int main (int argc, const char * argv[]) 
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

	if (argc > 1)
		[Search searchForXml:[NSString stringWithCString:argv[1]] locale:[NSString stringWithCString:argv[2]]];
		
    [pool drain];
    return 0;
}
