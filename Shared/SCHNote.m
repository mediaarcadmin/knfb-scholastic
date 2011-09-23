// 
//  SCHNote.m
//  Scholastic
//
//  Created by John S. Eddie on 31/01/2011.
//  Copyright 2011 BitWink Limited. All rights reserved.
//

#import "SCHNote.h"

#import "SCHLocationGraphics.h"
#import "UIColor+Extensions.h"
#import "SCHBookPoint.h"
#import "NSNumber+ObjectTypes.h"

// Constants
NSString * const kSCHNote = @"SCHNote";

@implementation SCHNote 

@dynamic Color;
@dynamic Value;
@dynamic Location;
@dynamic PrivateAnnotations;

- (UIColor *)NoteColor
{
    return([UIColor BITcolorWithHexString:self.Color]);
}

- (void)setNoteColor:(UIColor *)value
{
    self.Color = [value BIThexString];
}

- (NSString *)NoteText
{
    return self.Value;
}

- (void)setNoteText:(NSString *)NoteText
{
    self.Value = NoteText;   
}

- (NSUInteger)noteLayoutPage
{
    return [self.Location.Page intValue];
}

- (void)setNoteLayoutPage:(NSUInteger)layoutPage
{
    self.Location.Page = [NSNumber numberWithInt:layoutPage];
}

@end
