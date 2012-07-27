//
//  NSNumber+ObjectTypesTests.m
//  Scholastic
//
//  Created by John S. Eddie on 26/07/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "NSNumber+ObjectTypesTests.h"

#import "NSNumber+ObjectTypes.h"

@implementation NSNumber_ObjectTypesTests

- (void)testInitDRMQualifierNone
{
    NSNumber *drmQualifier = [[[NSNumber alloc] initWithDRMQualifier:kSCHDRMQualifiersNone] autorelease];
    
    STAssertEquals([drmQualifier DRMQualifierValue], 0, @"drmQualifier should be kSCHDRMQualifiersNone");
    STAssertEquals([drmQualifier isValidDRMQualifierValue], YES, @"drmQualifier should be valid");
}

- (void)testInitDRMQualifierFullWithDRM
{
    NSNumber *drmQualifier = [[[NSNumber alloc] initWithDRMQualifier:kSCHDRMQualifiersFullWithDRM] autorelease];
    
    STAssertEquals([drmQualifier DRMQualifierValue], 1, @"drmQualifier should be kSCHDRMQualifiersFullWithDRM");
    STAssertEquals([drmQualifier isValidDRMQualifierValue], YES, @"drmQualifier should be valid");
}

- (void)testInitDRMQualifierFullNoDRM
{
    NSNumber *drmQualifier = [[[NSNumber alloc] initWithDRMQualifier:kSCHDRMQualifiersFullNoDRM] autorelease];
    
    STAssertEquals([drmQualifier DRMQualifierValue], 2, @"drmQualifier should be kSCHDRMQualifiersFullNoDRM");
    STAssertEquals([drmQualifier isValidDRMQualifierValue], YES, @"drmQualifier should be valid");
}

- (void)testInitDRMQualifierSample
{
    NSNumber *drmQualifier = [[[NSNumber alloc] initWithDRMQualifier:kSCHDRMQualifiersSample] autorelease];
    
    STAssertEquals([drmQualifier DRMQualifierValue], 3, @"drmQualifier should be kSCHDRMQualifiersSample");
    STAssertEquals([drmQualifier isValidDRMQualifierValue], YES, @"drmQualifier should be valid");
}

- (void)testDRMQualifierNone
{
    NSNumber *drmQualifier = [NSNumber numberWithDRMQualifier:kSCHDRMQualifiersNone];
    
    STAssertEquals([drmQualifier DRMQualifierValue], 0, @"drmQualifier should be kSCHDRMQualifiersNone");
    STAssertEquals([drmQualifier isValidDRMQualifierValue], YES, @"drmQualifier should be valid");
}

- (void)testDRMQualifierFullWithDRM
{
    NSNumber *drmQualifier = [NSNumber numberWithDRMQualifier:kSCHDRMQualifiersFullWithDRM];
    
    STAssertEquals([drmQualifier DRMQualifierValue], 1, @"drmQualifier should be kSCHDRMQualifiersFullWithDRM");
    STAssertEquals([drmQualifier isValidDRMQualifierValue], YES, @"drmQualifier should be valid");
}

- (void)testDRMQualifierFullNoDRM
{
    NSNumber *drmQualifier = [NSNumber numberWithDRMQualifier:kSCHDRMQualifiersFullNoDRM];
    
    STAssertEquals([drmQualifier DRMQualifierValue], 2, @"drmQualifier should be kSCHDRMQualifiersFullNoDRM");
    STAssertEquals([drmQualifier isValidDRMQualifierValue], YES, @"drmQualifier should be valid");
}

- (void)testDRMQualifierSample
{
    NSNumber *drmQualifier = [NSNumber numberWithDRMQualifier:kSCHDRMQualifiersSample];
    
    STAssertEquals([drmQualifier DRMQualifierValue], 3, @"drmQualifier should be kSCHDRMQualifiersSample");
    STAssertEquals([drmQualifier isValidDRMQualifierValue], YES, @"drmQualifier should be valid");    
}

- (void)testDRMQualifierOutOfRange
{
    NSNumber *drmQualifier = [NSNumber numberWithDRMQualifier:-1];
    
    STAssertEquals([drmQualifier DRMQualifierValue], -1, @"drmQualifier should be -1");
    STAssertEquals([drmQualifier isValidDRMQualifierValue], NO, @"drmQualifier should not be valid");
    
    drmQualifier = [NSNumber numberWithDRMQualifier:4];
    
    STAssertEquals([drmQualifier DRMQualifierValue], 4, @"drmQualifier should be 4");
    STAssertEquals([drmQualifier isValidDRMQualifierValue], NO, @"drmQualifier should not be valid");
}

- (void)testPurchasedDRMQualifiers
{
    NSArray *purchasedDRMQualifiers = [NSNumber arrayOfPurchasedDRMQualifiers];
    
    STAssertNotNil(purchasedDRMQualifiers, @"Purchased DRMQualifiers should be not be nil");
    STAssertEquals([purchasedDRMQualifiers count], (NSUInteger)2, @"there should be 2 Purchased DRMQualifiers");
    STAssertEquals([purchasedDRMQualifiers containsObject:[NSNumber numberWithDRMQualifier:kSCHDRMQualifiersFullWithDRM]], YES, @"kSCHDRMQualifiersFullWithDRM should be in Purchased DRMQualifiers");
    STAssertEquals([purchasedDRMQualifiers containsObject:[NSNumber numberWithDRMQualifier:kSCHDRMQualifiersFullNoDRM]], YES, @"kSCHDRMQualifiersFullNoDRM should in Purchased DRMQualifiers");
}

@end
