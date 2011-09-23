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

@interface SCHNote (PrimitiveAccessors)

@property (nonatomic, retain) NSString *primitiveColor;

@end

@implementation SCHNote 

@dynamic Color;
@dynamic Value;
@dynamic Location;
@dynamic PrivateAnnotations;

- (UIColor *)Color
{
    [self willAccessValueForKey:@"Color"];
    UIColor *tmpValue = [UIColor BITcolorWithHexString:[self primitiveColor]];
    [self didAccessValueForKey:@"Color"];
    return(tmpValue);
}

- (void)setColor:(UIColor *)value
{
    [self willChangeValueForKey:@"Color"];
    [self setPrimitiveColor:[value BIThexString]];
    [self didChangeValueForKey:@"Color"];
}

//- (NSNumber *)NotePageNumber
//{
//    return [self.LocationGraphics Page];
//}
//
//- (void)setNotePageNumber:(NSNumber *)NotePageNumber
//{
//    self.LocationGraphics.Page = NotePageNumber;
//}
//
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

// Overriding description because it doesn't like the UIColor primitive
- (NSString *)description
{
    return [NSString stringWithFormat:@"<SCHNote: <%p> isDeleted: %d (entity: %@; id: %@)", self, ([self State] == [NSNumber numberWithStatus:kSCHStatusDeleted]), [[self entity] name], [self objectID]];
}

@end
