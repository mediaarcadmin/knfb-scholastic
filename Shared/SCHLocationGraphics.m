// 
//  SCHLocationGraphics.m
//  Scholastic
//
//  Created by John S. Eddie on 31/01/2011.
//  Copyright 2011 BitWink Limited. All rights reserved.
//

#import "SCHLocationGraphics.h"

#import "SCHNote.h"

// Constants
NSString * const kSCHLocationGraphics = @"SCHLocationGraphics";

@implementation SCHLocationGraphics 

@dynamic Page;
@dynamic Note;

- (void)setInitialValues
{
    self.Page = [NSNumber numberWithInteger:0];
}

@end
