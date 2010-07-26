//
//  NSString+validKeyString.m
//  Tab-Delimited Text Importer
//
//  Created by Jan on 26.07.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NSString+validKeyString.h"


@implementation NSString (validKeyString)

- (NSString *)validKeyString;
{
	NSString *asciiString = [[NSString alloc] 
							 initWithData:[self dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES] 
							 encoding:NSASCIIStringEncoding];
	
	NSMutableString *output = [NSMutableString string];
    BOOL makeNextCharacterUpperCase = NO;
    for (NSUInteger i = 0; i < [asciiString length]; i++) {
        unichar c = [asciiString characterAtIndex:i];
		
		if (i == 0) {
            [output appendString:[[NSString stringWithCharacters:&c length:1] lowercaseString]];
		}
        else if (c == ' ') {
            makeNextCharacterUpperCase = YES;
        } else if (makeNextCharacterUpperCase) {
            [output appendString:[[NSString stringWithCharacters:&c length:1] uppercaseString]];
            makeNextCharacterUpperCase = NO;
        } else {
            [output appendString:[NSString stringWithCharacters:&c length:1]];
        }
    }
	
	[asciiString release];
	
    return output;
	
}

@end
