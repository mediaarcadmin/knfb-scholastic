//
//  SCHBookDataTests.m
//  Scholastic
//
//  Created by Gordon Christie on 05/07/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHBookDataTests.h"
#import "SCHBookRange.h"
#import "SCHBookPoint.h"

@implementation SCHBookDataTests

- (void)testBookPoint
{
    SCHBookPoint *pointAtBeginning = [[[SCHBookPoint alloc] init] autorelease];
    pointAtBeginning.layoutPage = 1;
    pointAtBeginning.blockOffset = 0;
    pointAtBeginning.wordOffset = 0;
    pointAtBeginning.elementOffset = 0;
    
    SCHBookPoint *pointAlsoAtBeginning = [[[SCHBookPoint alloc] init] autorelease];
    pointAlsoAtBeginning.layoutPage = 1;
    pointAlsoAtBeginning.blockOffset = 0;
    pointAlsoAtBeginning.wordOffset = 0;
    pointAlsoAtBeginning.elementOffset = 0;
    
    SCHBookPoint *pointInMiddle = [[[SCHBookPoint alloc] init] autorelease];
    pointInMiddle.layoutPage = 10;
    pointInMiddle.blockOffset = 0;
    pointInMiddle.wordOffset = 0;
    pointInMiddle.elementOffset = 0;
    
    SCHBookPoint *pointAtEnd = [[[SCHBookPoint alloc] init] autorelease];
    pointAtEnd.layoutPage = 20;
    pointAtEnd.blockOffset = 0;
    pointAtEnd.wordOffset = 0;
    pointAtEnd.elementOffset = 0;
    
    
    STAssertTrue(([pointAtBeginning compare:pointInMiddle] == NSOrderedAscending), @"Point at beginning should be before point in middle.");
    STAssertTrue(([pointInMiddle compare:pointAtBeginning] == NSOrderedDescending), @"Point at beginning should be before point in middle.");
    STAssertTrue(([pointInMiddle compare:pointInMiddle] == NSOrderedSame), @"Point should be ordered as equal to itself.");
    STAssertTrue([pointInMiddle isEqual:pointInMiddle], @"Point should be equal to itself.");
    STAssertTrue([pointAtBeginning isEqual:pointAlsoAtBeginning], @"Points with equal values should be equal, even if they're different objects.");
    STAssertFalse([pointInMiddle isEqual:pointAtEnd], @"Points with different values should not be equal.");
    

    SCHBookPoint *firstPoint = [[[SCHBookPoint alloc] init] autorelease];
    SCHBookPoint *secondPoint = [[[SCHBookPoint alloc] init] autorelease];
    
    firstPoint.layoutPage = 1;
    firstPoint.blockOffset = 99;
    firstPoint.wordOffset = 99;
    firstPoint.elementOffset = 99;
    
    secondPoint.layoutPage = 2;
    secondPoint.blockOffset = 0;
    secondPoint.wordOffset = 0;
    secondPoint.elementOffset = 0;
    
    // layout page supercedes other offsets
    STAssertTrue([firstPoint compare:secondPoint] == NSOrderedAscending, @"Layout page of second point should be after first point");
    
    firstPoint.blockOffset = 0;
    secondPoint.layoutPage = 1;
    secondPoint.blockOffset = 1;
    
    // block offset supercedes word and element offsets
    STAssertTrue([firstPoint compare:secondPoint] == NSOrderedAscending, @"Block offset of second point should be after first point");
    
    firstPoint.wordOffset = 0;
    secondPoint.blockOffset = 0;
    secondPoint.wordOffset = 1;
    
    // word offset supercedes element offset
    STAssertTrue([firstPoint compare:secondPoint] == NSOrderedAscending, @"Word offset of second point should be after first point");

    firstPoint.elementOffset = 0;
    secondPoint.wordOffset = 0;
    secondPoint.elementOffset = 1;
    
    // test element offset
    STAssertTrue([firstPoint compare:secondPoint] == NSOrderedAscending, @"Element offset of second point should be after first point");

}

@end
