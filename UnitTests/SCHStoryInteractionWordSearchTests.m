//
//  SCHStoryInteractionWordSearchTests.m
//  Scholastic
//
//  Created by Neil Gall on 09/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "SCHStoryInteractionWordSearch.h"

@interface SCHStoryInteractionWordSearchTests : SenTestCase {}
@end

@implementation SCHStoryInteractionWordSearchTests

- (void)testWordMatch
{
    SCHStoryInteractionWordSearch *wordSearch = [[SCHStoryInteractionWordSearch alloc] init];
    wordSearch.words = [NSArray arrayWithObjects:@"Watch", @"Skate", @"Sleep", @"Brick", nil];
    
    STAssertEquals([wordSearch wordIndexForLetters:@"WATCH"], 0, @"word not matched");
    STAssertEquals([wordSearch wordIndexForLetters:@"SKATE"], 1, @"word not matched");
    STAssertEquals([wordSearch wordIndexForLetters:@"SLEEP"], 2, @"word not matched");
    STAssertEquals([wordSearch wordIndexForLetters:@"BRICK"], 3, @"word not matched");
    STAssertEquals([wordSearch wordIndexForLetters:@"GLUB"], NSNotFound, @"incorrect word matched");
}

@end
