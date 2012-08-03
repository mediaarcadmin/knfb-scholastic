//
//  SCHScholasticResponseParserTests.m
//  Scholastic
//
//  Created by John Eddie on 13/07/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHScholasticResponseParserTests.h"

#import "SCHScholasticResponseParser.h"

@interface SCHScholasticResponseParserTests ()

@property (nonatomic, retain) SCHScholasticResponseParser *scholasticResponseParser;

@end

@implementation SCHScholasticResponseParserTests

@synthesize scholasticResponseParser;

#pragma mark - Lifecycle methods

- (void)setUp
{
    self.scholasticResponseParser = [[[SCHScholasticResponseParser alloc] init] autorelease];
}

- (void)tearDown
{
    self.scholasticResponseParser = nil;
}

#pragma mark - General Tests

- (void)testNilXMLString
{
    NSDictionary *responseDictionary = nil;
    
    responseDictionary = [self.scholasticResponseParser parseXMLString:nil];
    STAssertNil(responseDictionary, @"passing nil to parseXMLString: should return nil");
}

- (void)testEmptyXMLStrings
{
    NSDictionary *responseDictionary = nil;
        
    responseDictionary = [self.scholasticResponseParser parseXMLString:@""];
    STAssertEquals([responseDictionary count], (NSUInteger)0, @"A '' XML string should return an empty dictionary");
    
    responseDictionary = [self.scholasticResponseParser parseXMLString:@" "];
    STAssertEquals([responseDictionary count], (NSUInteger)0, @"A ' ' XML string should return an empty dictionary");    
}

- (void)testValidXMLStrings
{
    NSDictionary *responseDictionary = nil;

    responseDictionary = [self.scholasticResponseParser parseXMLString:@"<container></container>"];
    STAssertNotNil(responseDictionary, @"A valid XML string should not return nil");
    STAssertEquals([responseDictionary count], (NSUInteger)0, @"A valid XML string with no values should return an empty dictionary");    

    responseDictionary = [self.scholasticResponseParser parseXMLString:@"<container><somethingelse/></container>"];
    STAssertNotNil(responseDictionary, @"A valid XML string should not return nil");
    STAssertEquals([responseDictionary count], (NSUInteger)0, @"A valid XML string with no values should return an empty dictionary");        

    responseDictionary = [self.scholasticResponseParser parseXMLString:@"<container><somethingelse/><somethingelse></somethingelse></container>"];
    STAssertNotNil(responseDictionary, @"A valid XML string should not return nil");
    STAssertEquals([responseDictionary count], (NSUInteger)0, @"A valid XML string with no values should return an empty dictionary");        

    responseDictionary = [self.scholasticResponseParser parseXMLString:@"<container><attribute name=\"attribute\" value=\"valueForAttribute\"/></container>"];
    STAssertNotNil(responseDictionary, @"A valid XML string should not return nil");
    STAssertEquals([responseDictionary count], (NSUInteger)1, @"Response dictionary should have 1 key/value");        
    
    NSString *attributeValue = [responseDictionary objectForKey:@"attribute"];
    STAssertNotNil(attributeValue, @"Response dictionary should have attribute key");        
    STAssertEqualObjects(attributeValue, @"valueForAttribute", @"Response dictionary should have valueForAttribute value for key attribute");        

    responseDictionary = [self.scholasticResponseParser parseXMLString:@"<container><somethingelse/><attribute name=\"attribute\" value=\"valueForAttribute\"/></container>"];
    STAssertNotNil(responseDictionary, @"A valid XML string should not return nil");
    STAssertEquals([responseDictionary count], (NSUInteger)1, @"Response dictionary should have 1 key/value");        
    
    responseDictionary = [self.scholasticResponseParser parseXMLString:@"<container><attribute name=\"attribute1\" value=\"valueForAttribute1\"/>"
                          @"<attribute name=\"attribute2\" value=\"valueForAttribute2\"/></container>"];
    STAssertNotNil(responseDictionary, @"A valid XML string should not return nil");    
    STAssertEquals([responseDictionary count], (NSUInteger)2, @"Response dictionary should have 2 key/value");        
    
    NSString *attributeValue1 = [responseDictionary objectForKey:@"attribute1"];
    STAssertNotNil(attributeValue1, @"Response dictionary should have attribute1 key");        
    STAssertEqualObjects(attributeValue1, @"valueForAttribute1", @"Response dictionary should have valueForAttribute1 value for key attribute1");        

    NSString *attributeValue2 = [responseDictionary objectForKey:@"attribute2"];
    STAssertNotNil(attributeValue2, @"Response dictionary should have attribute2 key");        
    STAssertEqualObjects(attributeValue2, @"valueForAttribute2", @"Response dictionary should have valueForAttribute2 value for key attribute2");            
}

- (void)testInvalidXMLStrings
{
    NSDictionary *responseDictionary = nil;

    responseDictionary = [self.scholasticResponseParser parseXMLString:@"abcdefghijklmnopqrstuvwxyz</\""];
    STAssertNil(responseDictionary, @"passing non XML string to parseXMLString: should return nil");
    
    responseDictionary = [self.scholasticResponseParser parseXMLString:@"<SchWS>"];
    STAssertNil(responseDictionary, @"passing XML with missing markup termination to parseXMLString: should return nil");    
    
    responseDictionary = [self.scholasticResponseParser parseXMLString:@"<SchWS><SchWS></SchWS>"];
    STAssertNil(responseDictionary, @"passing XML with missing markup termination to parseXMLString: should return nil");        
    
    responseDictionary = [self.scholasticResponseParser parseXMLString:@"<startsand"];
    STAssertNil(responseDictionary, @"passing non XML string to parseXMLString: should return nil");    
}

- (void)testErrorFromDictionary
{
    NSError *error = nil;
    
    error = [SCHScholasticResponseParser errorFromDictionary:nil];
    STAssertNil(error, @"passing nil to errorFromDictionary: should return nil");
    
    error = [SCHScholasticResponseParser errorFromDictionary:[NSDictionary dictionary]];
    STAssertNil(error, @"passing an empty dictionary to errorFromDictionary: should return nil");    
    
    error = [SCHScholasticResponseParser errorFromDictionary:[NSDictionary dictionaryWithObject:@"an error description" forKey:@"errorDesc"]];
    STAssertNil(error, @"passing a dictionary with no errorCode should return nil");    

    error = [SCHScholasticResponseParser errorFromDictionary:[NSDictionary dictionaryWithObject:[NSNull null] forKey:@"errorCode"]];
    STAssertNil(error, @"passing a dictionary with NSNull errorCode should return nil");    
}

- (void)testErrorFromDictionaryErrorResponse
{
    NSString *response = @"<SchWS><attribute name=\"errorCode\" value=\"200\"/></SchWS>";
    NSDictionary *responseDictionary = [self.scholasticResponseParser parseXMLString:response];
    
    NSError *error = [SCHScholasticResponseParser errorFromDictionary:responseDictionary];
    STAssertNotNil(error, @"passing an error dictionary without a description to errorFromDictionary: should not return nil");
    
    STAssertEquals([error code], 200,  @"error object should have code = 200");        

    response = @"<SchWS><attribute name=\"errorCode\" value=\"200\"/><attribute name=\"errorDesc\" value=\"invalid request\"/></SchWS>";
    
    responseDictionary = [self.scholasticResponseParser parseXMLString:response];
    
    error = [SCHScholasticResponseParser errorFromDictionary:responseDictionary];
    STAssertNotNil(error, @"passing an error dictionary to errorFromDictionary: should not return nil");
    
    STAssertEquals([error code], 200,  @"error object should have code = 200");    
    STAssertEqualObjects([error localizedDescription], @"invalid request",  @"error object should have localizedDescription = invalid request");        

    response = @"<SchWS></SchWS>";
    
    responseDictionary = [self.scholasticResponseParser parseXMLString:response];
    error = [SCHScholasticResponseParser errorFromDictionary:responseDictionary];    
    STAssertNil(error, @"passing an error dictionary with no error information should return nil");
    
    response = @"<SchWS><attribute name=\"errorDesc\" value=\"invalid request\"/></SchWS>";
    
    responseDictionary = [self.scholasticResponseParser parseXMLString:response];
    
    error = [SCHScholasticResponseParser errorFromDictionary:responseDictionary];
    STAssertNil(error, @"passing an error dictionary with no error code should return nil");
}

#pragma mark - Scholastic Authentication Tests

- (void)testScholasticAuthenticationValidResponse
{
    NSString *response = @"<SchWS><attribute name=\"token\" value=\"hhgpCZWXRhOfUOpAZpgacA== 6ryT1K+VB5L/K6KY+4XEBg==\"/></SchWS>";
    NSDictionary *responseDictionary = nil;
    NSString *token = nil;
    
    responseDictionary = [self.scholasticResponseParser parseXMLString:response];
    token = [responseDictionary objectForKey:@"token"];
    STAssertNotNil(token, @"a valid token should exist in the dictionary");
    STAssertEqualObjects(token, @"hhgpCZWXRhOfUOpAZpgacA== 6ryT1K+VB5L/K6KY+4XEBg==", @"a token should have a valid value");
    
    response = @"<SchWS><attribute name=\"token\"/></SchWS>";
    responseDictionary = [self.scholasticResponseParser parseXMLString:response];
    
    token = [responseDictionary objectForKey:@"token"];
    STAssertNotNil(token, @"a valid token should exist in the dictionary");
    STAssertEqualObjects(token, [NSNull null], @"the token should be NSNull if there is no value");    
    
    response = @"<SchWS><attribute value=\"hhgpCZWXRhOfUOpAZpgacA== 6ryT1K+VB5L/K6KY+4XEBg==\"/></SchWS>";
    responseDictionary = [self.scholasticResponseParser parseXMLString:response];
    
    token = [responseDictionary objectForKey:@"token"];
    STAssertNil(token, @"a value with no name should return nil");
}

#pragma mark - Scholastic GetInfo Tests

- (void)testScholasticGetInfoCOPPAYESResponse
{
    NSString *response = @"<SchWS><attribute name=\"COPPA_FLAG_KEY\" value=\"1\"/></SchWS>";
    NSDictionary *responseDictionary = [self.scholasticResponseParser parseXMLString:response];
    NSString *coppaFlag = coppaFlag = [responseDictionary objectForKey:@"COPPA_FLAG_KEY"];
    STAssertNotNil(coppaFlag, @"a valid COPPA_FLAG_KEY should exist in the dictionary");
    STAssertEqualObjects(coppaFlag, @"1", @"a COPPA_FLAG_KEY should have a valid value (true)");
}

- (void)testScholasticGetInfoCOPPANOResponse
{
    NSString *response = @"<SchWS><attribute name=\"COPPA_FLAG_KEY\" value=\"0\"/></SchWS>";
    NSDictionary *responseDictionary = [self.scholasticResponseParser parseXMLString:response];
    NSString *coppaFlag = coppaFlag = [responseDictionary objectForKey:@"COPPA_FLAG_KEY"];
    STAssertNotNil(coppaFlag, @"a valid COPPA_FLAG_KEY should exist in the dictionary");
    STAssertEqualObjects(coppaFlag, @"0", @"a COPPA_FLAG_KEY should have a valid value (false)");
}

- (void)testScholasticGetInfoCOPPANilResponse
{
    NSString *response = @"<SchWS><attribute name=\"COPPA_FLAG_KEY\"/></SchWS>";
    NSDictionary *responseDictionary = [self.scholasticResponseParser parseXMLString:response];    
    NSString *coppaFlag = [responseDictionary objectForKey:@"COPPA_FLAG_KEY"];
    STAssertNotNil(coppaFlag, @"a valid COPPA_FLAG_KEY should exist in the dictionary");
    STAssertEqualObjects(coppaFlag, [NSNull null], @"COPPA_FLAG_KEY should be NSNull if there is no value");        
}

- (void)testScholasticGetInfoSPSIDResponse
{
    NSString *response = @"<SchWS><attribute name=\"spsid\" value=\"123456\"/></SchWS>";
    NSDictionary *responseDictionary = [self.scholasticResponseParser parseXMLString:response];
    NSString *spsId = [responseDictionary objectForKey:@"spsid"];
    STAssertNotNil(spsId, @"a valid spsid should exist in the dictionary");
    STAssertEqualObjects(spsId, @"123456", @"a spsid should have a valid value (123456)");    
}

- (void)testScholasticGetInfoCOPPAANDSPSIDResponse
{
    NSString *response = nil;
    NSDictionary *responseDictionary = nil;
    NSString *coppaFlag = nil;
    NSString *spsId = nil;
    
    response = @"<SchWS><attribute name=\"COPPA_FLAG_KEY\" value=\"1\"/><attribute name=\"spsid\" value=\"123456\"/></SchWS>";
    responseDictionary = [self.scholasticResponseParser parseXMLString:response];

    coppaFlag = [responseDictionary objectForKey:@"COPPA_FLAG_KEY"];
    STAssertNotNil(coppaFlag, @"a valid COPPA_FLAG_KEY should exist in the dictionary");
    STAssertEqualObjects(coppaFlag, @"1", @"a COPPA_FLAG_KEY should have a valid value (true)");
    
    spsId = [responseDictionary objectForKey:@"spsid"];
    STAssertNotNil(spsId, @"a valid spsid should exist in the dictionary");
    STAssertEqualObjects(spsId, @"123456", @"a spsid should have a valid value (123456)");    
}

- (void)testScholasticGetInfoMissingAttributesResponse
{
    NSString *response = nil;
    NSDictionary *responseDictionary = nil;
    
    response = @"<SchWS><attribute value=\"1\"/></SchWS>";
    responseDictionary = [self.scholasticResponseParser parseXMLString:response];
    
    NSString *coppaFlag = [responseDictionary objectForKey:@"COPPA_FLAG_KEY"];
    STAssertNil(coppaFlag, @"missing COPPA_FLAG_KEY flag should return nil"); 
    
    NSString *spsId = [responseDictionary objectForKey:@"spsid"];
    STAssertNil(spsId, @"missing spsid flag should return nil"); 
}

- (void)testScholasticGetInfoMissingCOPPANameInAttributeResponse
{
    NSString *response = @"<SchWS><attribute value=\"1\"/></SchWS>";
    NSDictionary *responseDictionary = [self.scholasticResponseParser parseXMLString:response];    
    NSString *coppaFlag = [responseDictionary objectForKey:@"COPPA_FLAG_KEY"];
    STAssertNil(coppaFlag, @"a value with no name should return nil");     
}

@end
