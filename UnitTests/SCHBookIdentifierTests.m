//
//  SCHBookIdentifierTests.m
//  Scholastic
//
//  Created by John S. Eddie on 26/07/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHBookIdentifierTests.h"

#import "SCHBookIdentifier.h"
#import "NSNumber+ObjectTypes.h"
#import "SCHLibreAccessConstants.h"

@implementation SCHBookIdentifierTests

#pragma mark - Constructor tests

- (void)testNilISBN
{
    SCHBookIdentifier *bookIdentifier = [[SCHBookIdentifier alloc] initWithISBN:nil
                                                                    DRMQualifier:[NSNumber numberWithDRMQualifier:kSCHDRMQualifiersFullWithDRM]];
    
    STAssertNil(bookIdentifier, @"bookIdentifier should be nil when ISBN is nil");
}

- (void)testNilDRMQualifier
{
    SCHBookIdentifier *bookIdentifier = [[SCHBookIdentifier alloc] initWithISBN:@"9780545366779"
                                                                   DRMQualifier:nil];
    
    STAssertNil(bookIdentifier, @"bookIdentifier should be nil when DRMQualifier is nil");
}

- (void)testNilISBNAndDRMQualifier
{
    SCHBookIdentifier *bookIdentifier = [[SCHBookIdentifier alloc] initWithISBN:nil
                                                                   DRMQualifier:nil];
    
    STAssertNil(bookIdentifier, @"bookIdentifier should be nil when ISBN and DRMQualifier are both nil");
}

- (void)testNilObject
{
    SCHBookIdentifier *bookIdentifier = [[SCHBookIdentifier alloc] initWithObject:nil];
    
    STAssertNil(bookIdentifier, @"bookIdentifier should be nil when object is nil");
}

- (void)testNilEncodedString
{
    SCHBookIdentifier *bookIdentifier = [[SCHBookIdentifier alloc] initWithEncodedString:nil];
    
    STAssertNil(bookIdentifier, @"bookIdentifier should be nil when encoded string is nil");
}

- (void)testEmptyObject
{
    SCHBookIdentifier *bookIdentifier = [[SCHBookIdentifier alloc] initWithObject:[NSDictionary dictionary]];
    
    STAssertNil(bookIdentifier, @"bookIdentifier should be nil when object is empty");
}

- (void)testNullObjects
{
    NSDictionary *object = [NSDictionary dictionaryWithObjectsAndKeys:[NSNull null], kSCHLibreAccessWebServiceContentIdentifier,
                            [NSNull null], kSCHLibreAccessWebServiceDRMQualifier,
                            nil];
    SCHBookIdentifier *bookIdentifier = [[SCHBookIdentifier alloc] initWithObject:object];
    
    STAssertNil(bookIdentifier, @"bookIdentifier should be nil when object is has NSNull entries");
}

- (void)testEmptyISBN
{
    SCHBookIdentifier *bookIdentifier = [[SCHBookIdentifier alloc] initWithISBN:@""
                                                                   DRMQualifier:[NSNumber numberWithDRMQualifier:kSCHDRMQualifiersFullWithDRM]];
    
    STAssertNil(bookIdentifier, @"bookIdentifier should be nil when ISBN is empty");
    
    bookIdentifier = [[SCHBookIdentifier alloc] initWithISBN:@"   "
                                                DRMQualifier:[NSNumber numberWithDRMQualifier:kSCHDRMQualifiersFullWithDRM]];
    
    STAssertNil(bookIdentifier, @"bookIdentifier should be nil when ISBN is empty");
}

- (void)testEmptyEncodedString
{
    SCHBookIdentifier *bookIdentifier = [[SCHBookIdentifier alloc] initWithEncodedString:@""];
    
    STAssertNil(bookIdentifier, @"bookIdentifier should be nil when encoded string is empty");
}

- (void)testNoEncodingInString
{
    SCHBookIdentifier *bookIdentifier = [[SCHBookIdentifier alloc] initWithEncodedString:@"9780545366779"];
    
    STAssertNil(bookIdentifier, @"bookIdentifier should be nil when encoded string is empty");
}

- (void)testMissingISBNInEncodedString
{
    SCHBookIdentifier *bookIdentifier = [[SCHBookIdentifier alloc] initWithEncodedString:@"§6"];
    
    STAssertNil(bookIdentifier, @"bookIdentifier should be nil when encoded string is empty");
}

- (void)testMissingDRMQualifierInEncodedString
{
    SCHBookIdentifier *bookIdentifier = [[SCHBookIdentifier alloc] initWithEncodedString:@"9780545366779§"];
    
    STAssertNotNil(bookIdentifier, @"bookIdentifier should be not be nil");
    STAssertEqualObjects(bookIdentifier.DRMQualifier, [NSNumber numberWithDRMQualifier:kSCHDRMQualifiersNone], @"missing drm qualifier from encoded string should be kSCHDRMQualifiersNone");
}

- (void)testEncodedStringWrongOrder
{
    SCHBookIdentifier *bookIdentifier = [[SCHBookIdentifier alloc] initWithEncodedString:@"6§9780545366779"];
    
    STAssertNil(bookIdentifier, @"bookIdentifier should be nil when encoded string is empty");
}

- (void)testEncodedStringWithWhiteSpace
{
    SCHBookIdentifier *bookIdentifier = [[SCHBookIdentifier alloc] initWithEncodedString:@" 6 § 9780545366779 "];
    
    STAssertNil(bookIdentifier, @"bookIdentifier should be nil when encoded string is empty");
}

- (void)testMutableISBN
{
    NSMutableString *isbn = [NSMutableString stringWithString:@"9780545366779"];
    SCHBookIdentifier *bookIdentifier = [[SCHBookIdentifier alloc] initWithISBN:isbn
                                                                   DRMQualifier:[NSNumber numberWithDRMQualifier:kSCHDRMQualifiersFullWithDRM]];
    [isbn setString:@"1234567890"];
    STAssertEqualObjects(bookIdentifier.isbn, @"9780545366779", @"bookIdentifier sisbn should be 9780545366779 even when modified");
}

- (void)testOutOfRangeDRMQualifier
{
    SCHBookIdentifier *bookIdentifier = [[SCHBookIdentifier alloc] initWithISBN:@"9780545366779"
                                                                   DRMQualifier:[NSNumber numberWithInt:-1]];
    
    STAssertNil(bookIdentifier, @"bookIdentifier should be nil when DRMQualifier is invalid (-1)");
    
    bookIdentifier = [[SCHBookIdentifier alloc] initWithISBN:@"9780545366779"
                                                DRMQualifier:[NSNumber numberWithInt:100]];
    
    STAssertNil(bookIdentifier, @"bookIdentifier should be nil when DRMQualifier is invalid (100)");
}

- (void)testValidISBNAndDRMQualifier
{
    SCHBookIdentifier *bookIdentifier = [[SCHBookIdentifier alloc] initWithISBN:@"9780545366779"
                                                                   DRMQualifier:[NSNumber numberWithDRMQualifier:kSCHDRMQualifiersFullWithDRM]];
    
    STAssertNotNil(bookIdentifier, @"bookIdentifier should not be nil");
    STAssertEqualObjects(bookIdentifier.isbn, @"9780545366779", @"ISBN's should be equal");
    STAssertEqualObjects(bookIdentifier.DRMQualifier, [NSNumber numberWithDRMQualifier:kSCHDRMQualifiersFullWithDRM], @"DRMQualifier should be equal");
}

- (void)testValidObjects
{
    NSDictionary *object = [NSDictionary dictionaryWithObjectsAndKeys:@"9780545366779", kSCHLibreAccessWebServiceContentIdentifier,
                            [NSNumber numberWithDRMQualifier:kSCHDRMQualifiersFullWithDRM], kSCHLibreAccessWebServiceDRMQualifier,
                            nil];
    SCHBookIdentifier *bookIdentifier = [[SCHBookIdentifier alloc] initWithObject:object];
    
    STAssertNotNil(bookIdentifier, @"bookIdentifier should not be nil");
    STAssertEqualObjects(bookIdentifier.isbn, @"9780545366779", @"ISBN's should be equal");
    STAssertEqualObjects(bookIdentifier.DRMQualifier, [NSNumber numberWithDRMQualifier:kSCHDRMQualifiersFullWithDRM], @"DRMQualifier should be equal");
}

- (void)testValidEncodedString
{
    SCHBookIdentifier *bookIdentifier = [[SCHBookIdentifier alloc] initWithEncodedString:@"9780545366779§1"];
    
    STAssertNotNil(bookIdentifier, @"bookIdentifier should not be nil");
    STAssertEqualObjects(bookIdentifier.isbn, @"9780545366779", @"ISBN's should be equal");
    STAssertEqualObjects(bookIdentifier.DRMQualifier, [NSNumber numberWithDRMQualifier:1], @"DRMQualifier should be equal");
}

- (void)testDRMQualifiersNone
{
    SCHBookIdentifier *bookIdentifier = [[SCHBookIdentifier alloc] initWithISBN:@"9780545366779"
                                                                   DRMQualifier:[NSNumber numberWithDRMQualifier:kSCHDRMQualifiersNone]];
    
    STAssertNotNil(bookIdentifier, @"bookIdentifier should not be nil");
    STAssertEqualObjects(bookIdentifier.DRMQualifier, [NSNumber numberWithDRMQualifier:kSCHDRMQualifiersNone], @"kSCHDRMQualifiersNone should be valid");    
}

- (void)testDRMQualifiersFullWithDRM
{
    SCHBookIdentifier *bookIdentifier = [[SCHBookIdentifier alloc] initWithISBN:@"9780545366779"
                                                                   DRMQualifier:[NSNumber numberWithDRMQualifier:kSCHDRMQualifiersFullWithDRM]];
    
    STAssertNotNil(bookIdentifier, @"bookIdentifier should not be nil");
    STAssertEqualObjects(bookIdentifier.DRMQualifier, [NSNumber numberWithDRMQualifier:kSCHDRMQualifiersFullWithDRM], @"kSCHDRMQualifiersFullWithDRM should be valid");
}

- (void)testDRMQualifiersFullNoDRM
{
    SCHBookIdentifier *bookIdentifier = [[SCHBookIdentifier alloc] initWithISBN:@"9780545366779"
                                                                   DRMQualifier:[NSNumber numberWithDRMQualifier:kSCHDRMQualifiersFullNoDRM]];
    
    STAssertNotNil(bookIdentifier, @"bookIdentifier should not be nil");
    STAssertEqualObjects(bookIdentifier.DRMQualifier, [NSNumber numberWithDRMQualifier:kSCHDRMQualifiersFullNoDRM], @"kSCHDRMQualifiersFullNoDRM should be valid");
}

- (void)testDRMQualifiersSample
{
    SCHBookIdentifier *bookIdentifier = [[SCHBookIdentifier alloc] initWithISBN:@"9780545366779"
                                                                   DRMQualifier:[NSNumber numberWithDRMQualifier:kSCHDRMQualifiersSample]];
    
    STAssertNotNil(bookIdentifier, @"bookIdentifier should not be nil");
    STAssertEqualObjects(bookIdentifier.DRMQualifier, [NSNumber numberWithDRMQualifier:kSCHDRMQualifiersSample], @"kSCHDRMQualifiersSample should be valid");
}

#pragma mark - comparison tests

- (void)testNilIsEquals
{
    SCHBookIdentifier *bookIdentifier = [[SCHBookIdentifier alloc] initWithISBN:@"9780545366779"
                                                                   DRMQualifier:[NSNumber numberWithDRMQualifier:kSCHDRMQualifiersFullWithDRM]];
    
    STAssertEquals([bookIdentifier isEqual:nil], NO, @"nil comparison should return NO");
}

- (void)testInvalidObjectIsEquals
{
    SCHBookIdentifier *bookIdentifier = [[SCHBookIdentifier alloc] initWithISBN:@"9780545366779"
                                                                   DRMQualifier:[NSNumber numberWithDRMQualifier:kSCHDRMQualifiersFullWithDRM]];
    
    STAssertEquals([bookIdentifier isEqual:[NSNull null]], NO, @"objects other than SCHBookIdentifiers should return NO");
}

- (void)testDifferentISBNIsEquals
{
    SCHBookIdentifier *bookIdentifier = [[SCHBookIdentifier alloc] initWithISBN:@"9780545366779"
                                                                   DRMQualifier:[NSNumber numberWithDRMQualifier:kSCHDRMQualifiersFullWithDRM]];
    SCHBookIdentifier *bookIdentifier2 = [[SCHBookIdentifier alloc] initWithISBN:@"9780545366778"
                                                                   DRMQualifier:[NSNumber numberWithDRMQualifier:kSCHDRMQualifiersFullWithDRM]];
    
    STAssertEquals([bookIdentifier isEqual:bookIdentifier2], NO, @"different ISBN comparison should return NO");
    STAssertEquals([bookIdentifier2 isEqual:bookIdentifier], NO, @"different ISBN comparison should return NO");
}

- (void)testDifferentDRMQualifiers
{
    SCHBookIdentifier *bookIdentifier = [[SCHBookIdentifier alloc] initWithISBN:@"9780545366779"
                                                                   DRMQualifier:[NSNumber numberWithDRMQualifier:kSCHDRMQualifiersFullWithDRM]];
    SCHBookIdentifier *bookIdentifier2 = [[SCHBookIdentifier alloc] initWithISBN:@"9780545366779"
                                                                    DRMQualifier:[NSNumber numberWithDRMQualifier:kSCHDRMQualifiersFullNoDRM]];
    
    STAssertEquals([bookIdentifier isEqual:bookIdentifier2], NO, @"different DRMQualifier comparison should return NO");
    STAssertEquals([bookIdentifier2 isEqual:bookIdentifier], NO, @"different DRMQualifier comparison should return NO");
}

- (void)testDifferentISBNAndDRMQualifierIsEquals
{
    SCHBookIdentifier *bookIdentifier = [[SCHBookIdentifier alloc] initWithISBN:@"9780545366779"
                                                                   DRMQualifier:[NSNumber numberWithDRMQualifier:kSCHDRMQualifiersFullWithDRM]];
    SCHBookIdentifier *bookIdentifier2 = [[SCHBookIdentifier alloc] initWithISBN:@"9780545366778"
                                                                    DRMQualifier:[NSNumber numberWithDRMQualifier:kSCHDRMQualifiersFullNoDRM]];
    
    STAssertEquals([bookIdentifier isEqual:bookIdentifier2], NO, @"different ISBN comparison should return NO");
    STAssertEquals([bookIdentifier2 isEqual:bookIdentifier], NO, @"different ISBN comparison should return NO");
}

- (void)testISBNAndDRMQualifierIsEquals
{
    SCHBookIdentifier *bookIdentifier = [[SCHBookIdentifier alloc] initWithISBN:@"9780545366779"
                                                                   DRMQualifier:[NSNumber numberWithDRMQualifier:kSCHDRMQualifiersFullWithDRM]];
    SCHBookIdentifier *bookIdentifier2 = [[SCHBookIdentifier alloc] initWithISBN:@"9780545366779"
                                                                    DRMQualifier:[NSNumber numberWithDRMQualifier:kSCHDRMQualifiersFullWithDRM]];
    
    STAssertEquals([bookIdentifier isEqual:bookIdentifier2], YES, @"book identifiers should be equal");
    STAssertEquals([bookIdentifier2 isEqual:bookIdentifier], YES, @"book identifiers should be equal");
}

- (void)testCompareISBNOrdering
{
    SCHBookIdentifier *bookIdentifier = [[SCHBookIdentifier alloc] initWithISBN:@"9780545366778"
                                                                   DRMQualifier:[NSNumber numberWithDRMQualifier:kSCHDRMQualifiersFullWithDRM]];
    SCHBookIdentifier *bookIdentifier2 = [[SCHBookIdentifier alloc] initWithISBN:@"9780545366779"
                                                                    DRMQualifier:[NSNumber numberWithDRMQualifier:kSCHDRMQualifiersFullWithDRM]];
    
    STAssertEquals([bookIdentifier compare:bookIdentifier2], NSOrderedAscending, @"9780545366778 should be smaller than 9780545366779");
    STAssertEquals([bookIdentifier2 compare:bookIdentifier], NSOrderedDescending, @"9780545366779 should be smaller than 9780545366778");
}

- (void)testCompareDRMQualifierOrdering
{
    SCHBookIdentifier *bookIdentifier = [[SCHBookIdentifier alloc] initWithISBN:@"9780545366779"
                                                                   DRMQualifier:[NSNumber numberWithDRMQualifier:kSCHDRMQualifiersFullWithDRM]];
    SCHBookIdentifier *bookIdentifier2 = [[SCHBookIdentifier alloc] initWithISBN:@"9780545366779"
                                                                    DRMQualifier:[NSNumber numberWithDRMQualifier:kSCHDRMQualifiersFullNoDRM]];
    
    STAssertEquals([bookIdentifier compare:bookIdentifier2], NSOrderedAscending, @"kSCHDRMQualifiersFullWithDRM should be smaller than kSCHDRMQualifiersFullNoDRM");
    STAssertEquals([bookIdentifier2 compare:bookIdentifier], NSOrderedDescending, @"kSCHDRMQualifiersFullNoDRM should be smaller than kSCHDRMQualifiersFullWithDRM");
}

- (void)testISBNAndDRMQualifierOrderingEqual
{
    SCHBookIdentifier *bookIdentifier = [[SCHBookIdentifier alloc] initWithISBN:@"9780545366779"
                                                                   DRMQualifier:[NSNumber numberWithDRMQualifier:kSCHDRMQualifiersFullWithDRM]];
    SCHBookIdentifier *bookIdentifier2 = [[SCHBookIdentifier alloc] initWithISBN:@"9780545366779"
                                                                    DRMQualifier:[NSNumber numberWithDRMQualifier:kSCHDRMQualifiersFullWithDRM]];
    
    STAssertEquals([bookIdentifier compare:bookIdentifier2], NSOrderedSame, @"book identifiers should be equal");
    STAssertEquals([bookIdentifier2 compare:bookIdentifier], NSOrderedSame, @"book identifiers should be equal");
}

- (void)testISBNAndDRMQualifierCompare
{
    SCHBookIdentifier *bookIdentifier = [[SCHBookIdentifier alloc] initWithISBN:@"9780545366779"
                                                                   DRMQualifier:[NSNumber numberWithDRMQualifier:kSCHDRMQualifiersFullWithDRM]];
    SCHBookIdentifier *bookIdentifier2 = [[SCHBookIdentifier alloc] initWithISBN:@"9780545366779"
                                                                    DRMQualifier:[NSNumber numberWithDRMQualifier:kSCHDRMQualifiersFullWithDRM]];
    
    STAssertEquals([bookIdentifier compare:bookIdentifier2], NSOrderedSame, @"book identifiers should be equal");
    STAssertEquals([bookIdentifier2 compare:bookIdentifier], NSOrderedSame, @"book identifiers should be equal");
}

#pragma mark - encoding tests

- (void)testEncodeAsString
{
    SCHBookIdentifier *bookIdentifier = [[SCHBookIdentifier alloc] initWithISBN:@"9780545366779"
                                                                   DRMQualifier:[NSNumber numberWithDRMQualifier:kSCHDRMQualifiersFullWithDRM]];
    
    STAssertEqualObjects([bookIdentifier encodeAsString], @"9780545366779§1", @"9780545366779§1 is the correct encoding string");
}

@end
