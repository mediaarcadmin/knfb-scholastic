//
//  SCHMakeNullNilTests.m
//  Scholastic
//
//  Created by John S. Eddie on 17/09/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHMakeNullNilTests.h"

#import "SCHMakeNullNil.h"

@implementation SCHMakeNullNilTests

- (void)testNilMakeNullNil
{
    id response = makeNullNil(nil);
    STAssertNil(response, @"passing nil to makeNilNul: should return nil");
}

- (void)testNullMakeNullNil
{
    id response = makeNullNil([NSNull null]);
    STAssertNil(response, @"passing [NSNull null] to makeNilNul: should return nil");
}

- (void)testNSStringMakeNullNil
{
    NSString *aString = @"A String";

    id response = makeNullNil(aString);
    STAssertNotNil(response, @"passing an NSString object to makeNilNul: should return the object");
}

- (void)testNSArrayMakeNullNil
{
    NSArray *anArray = [NSArray array];

    id response = makeNullNil(anArray);
    STAssertNotNil(response, @"passing an NSArray object to makeNilNul: should return the object");
}

@end
