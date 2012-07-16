//
//  SCHXPSKNFBMetadataFileParserTests.m
//  Scholastic
//
//  Created by John Eddie on 16/07/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHXPSKNFBMetadataFileParserTests.h"

#import "SCHXPSKNFBMetadataFileParser.h"

@interface SCHXPSKNFBMetadataFileParserTests ()

@property (nonatomic, retain) SCHXPSKNFBMetadataFileParser *metadataFileParser;

@end

@implementation SCHXPSKNFBMetadataFileParserTests

@synthesize metadataFileParser;

#pragma mark - Lifecycle methods

- (void)setUp
{
    self.metadataFileParser = [[[SCHXPSKNFBMetadataFileParser alloc] init] autorelease];
}

- (void)tearDown
{
    self.metadataFileParser = nil;
}

#pragma mark - General Tests

- (void)testEmptyXMLData
{
    NSDictionary *responseDictionary = nil;
    
    responseDictionary = [self.metadataFileParser parseXMLData:nil];
    STAssertNil(responseDictionary, @"passing nil to parseXMLData: should return nil");
    
    responseDictionary = [self.metadataFileParser parseXMLData:[NSData data]];
    STAssertEquals([responseDictionary count], (NSUInteger)0, @"No data should return an empty dictionary");    
}

- (void)testValidXMLData
{
    NSDictionary *responseDictionary = nil;
    
    responseDictionary = [self.metadataFileParser parseXMLData:[@"<Metadata PackagerVersion=\"1.1.1094.0\" FormatVersion=\"1.0.2.0\" Source=\"0b43f6ac6244810d8c2f94841dac714b\">"
                          @"<Edition Name=\"1\" />"
                          @"<Identifier ISBN=\"9780545368896\" />"
                          @"<Features />"
                          @"<PageStatistics MaxWidth=\"504\" MaxHeight=\"732.16\" />"
                          @"<Source Type=\"PDF\" />"
                          @"<View Default=\"2UP\" />"
                          @"<KNFBConv Build=\"1094\" When=\"3/16/2011 10:39:48 AM\" CommandLine=\"&quot;C:\\KNFB\\Converter\\Converter_Scholastic_1094\\KNFBConv.exe&quot;  -a -v=10 -f=Z:\\Convert\\Ready_To_Run\\20110315Toc\\9780545368896.pdf -outdir=Z:\\Convert\\Ready_To_Run\\20110315Toc\\Converted -p=false -isbn=file -rights -replaceisbn -tracparams\" />"
                          @"<Dimensions Depth=\"7.625\" Width=\"5.25\" />"
                          @"<Language Text=\"ENG\" />"
                          @"<Contributor Author=\"by Tony Abbott, illustrated by Tim Jessell\" />"
                          @"<Title Main=\"The Secrets of Droon #1: The Hidden Stairs and the Magic Carpet\" />"
                          @"<Subject Subject=\"JUV037000\" />"
                          @"<Scholastic BookCategory=\"Novel - Middle Grade\" />"
                          @"</Metadata>" dataUsingEncoding:NSUTF8StringEncoding]];
    
    STAssertNotNil(responseDictionary, @"Valid XML data should not return nil");
    STAssertEquals([responseDictionary count], (NSUInteger)3, @"Response dictionary should have 3 key/values");        
    
    NSString *authorValue = [responseDictionary objectForKey:@"Author"];
    STAssertNotNil(authorValue, @"Response dictionary should have Author key");        
    STAssertEqualObjects(authorValue, @"by Tony Abbott, illustrated by Tim Jessell", @"Response dictionary should have authorValue value for key Author");        

    NSString *titleValue = [responseDictionary objectForKey:@"Title"];
    STAssertNotNil(titleValue, @"Response dictionary should have Title key");        
    STAssertEqualObjects(titleValue, @"The Secrets of Droon #1: The Hidden Stairs and the Magic Carpet", @"Response dictionary should have titleValue value for key Title");        

    NSString *isbnValue = [responseDictionary objectForKey:@"ISBN"];
    STAssertNotNil(isbnValue, @"Response dictionary should have ISBN key");        
    STAssertEqualObjects(isbnValue, @"9780545368896", @"Response dictionary should have isbnValue value for key ISBN");        
}

- (void)testValidXMLDataWithMissingAttributesWithPartialAttributes
{
    NSDictionary *responseDictionary = [self.metadataFileParser parseXMLData:[@"<Metadata PackagerVersion=\"1.1.1094.0\" FormatVersion=\"1.0.2.0\" Source=\"0b43f6ac6244810d8c2f94841dac714b\">"
                                                                              @"<Edition Name=\"1\" />"
                                                                              @"<Identifier />"
                                                                              @"<Features />"
                                                                              @"<PageStatistics MaxWidth=\"504\" MaxHeight=\"732.16\" />"
                                                                              @"<Source Type=\"PDF\" />"
                                                                              @"<View Default=\"2UP\" />"
                                                                              @"<KNFBConv Build=\"1094\" When=\"3/16/2011 10:39:48 AM\" CommandLine=\"&quot;C:\\KNFB\\Converter\\Converter_Scholastic_1094\\KNFBConv.exe&quot;  -a -v=10 -f=Z:\\Convert\\Ready_To_Run\\20110315Toc\\9780545368896.pdf -outdir=Z:\\Convert\\Ready_To_Run\\20110315Toc\\Converted -p=false -isbn=file -rights -replaceisbn -tracparams\" />"
                                                                              @"<Dimensions Depth=\"7.625\" Width=\"5.25\" />"
                                                                              @"<Language Text=\"ENG\" />"
                                                                              @"<Contributor />"
                                                                              @"<Title />"
                                                                              @"<Subject Subject=\"JUV037000\" />"
                                                                              @"<Scholastic BookCategory=\"Novel - Middle Grade\" />"
                                                                              @"</Metadata>" dataUsingEncoding:NSUTF8StringEncoding]];
    
    STAssertNotNil(responseDictionary, @"Valid XML data should not return nil");
    STAssertEquals([responseDictionary count], (NSUInteger)0, @"Response dictionary should have 0 key/values");        
    
    NSString *authorValue = [responseDictionary objectForKey:@"Author"];
    STAssertNil(authorValue, @"Response dictionary should not contain Author key");        
    
    NSString *titleValue = [responseDictionary objectForKey:@"Title"];
    STAssertNil(titleValue, @"Response dictionary should not contain Title key");        
    
    NSString *isbnValue = [responseDictionary objectForKey:@"ISBN"];
    STAssertNil(isbnValue, @"Response dictionary should not contain ISBN key");        
}

- (void)testValidXMLDataWithMissingAttributes
{
    NSDictionary *responseDictionary = [self.metadataFileParser parseXMLData:[@"<Metadata PackagerVersion=\"1.1.1094.0\" FormatVersion=\"1.0.2.0\" Source=\"0b43f6ac6244810d8c2f94841dac714b\">"
                                                                              @"<Edition Name=\"1\" />"
                                                                              @"<Features />"
                                                                              @"<PageStatistics MaxWidth=\"504\" MaxHeight=\"732.16\" />"
                                                                              @"<Source Type=\"PDF\" />"
                                                                              @"<View Default=\"2UP\" />"
                                                                              @"<KNFBConv Build=\"1094\" When=\"3/16/2011 10:39:48 AM\" CommandLine=\"&quot;C:\\KNFB\\Converter\\Converter_Scholastic_1094\\KNFBConv.exe&quot;  -a -v=10 -f=Z:\\Convert\\Ready_To_Run\\20110315Toc\\9780545368896.pdf -outdir=Z:\\Convert\\Ready_To_Run\\20110315Toc\\Converted -p=false -isbn=file -rights -replaceisbn -tracparams\" />"
                                                                              @"<Dimensions Depth=\"7.625\" Width=\"5.25\" />"
                                                                              @"<Language Text=\"ENG\" />"
                                                                              @"<Subject Subject=\"JUV037000\" />"
                                                                              @"<Scholastic BookCategory=\"Novel - Middle Grade\" />"
                                                                              @"</Metadata>" dataUsingEncoding:NSUTF8StringEncoding]];
    
    STAssertNotNil(responseDictionary, @"Valid XML data should not return nil");
    STAssertEquals([responseDictionary count], (NSUInteger)0, @"Response dictionary should have 0 key/values");        
    
    NSString *authorValue = [responseDictionary objectForKey:@"Author"];
    STAssertNil(authorValue, @"Response dictionary should not contain Author key");        
    
    NSString *titleValue = [responseDictionary objectForKey:@"Title"];
    STAssertNil(titleValue, @"Response dictionary should not contain Title key");        
    
    NSString *isbnValue = [responseDictionary objectForKey:@"ISBN"];
    STAssertNil(isbnValue, @"Response dictionary should not contain ISBN key");        
    
}

- (void)testInvalidXMLData
{
    NSDictionary *responseDictionary = nil;
    
    responseDictionary = [self.metadataFileParser parseXMLData:[@"abcdefghijklmnopqrstuvwxyz</\"" dataUsingEncoding:NSUTF8StringEncoding]];
    STAssertNil(responseDictionary, @"passing non XML data to parseXMLData: should return nil");
    
    responseDictionary = [self.metadataFileParser parseXMLData:[@"<Metadata>" dataUsingEncoding:NSUTF8StringEncoding]];
    STAssertNil(responseDictionary, @"passing XML with missing markup termination to parseXMLData: should return nil");    
    
    responseDictionary = [self.metadataFileParser parseXMLData:[@"<Metadata><Metadata></Metadata>" dataUsingEncoding:NSUTF8StringEncoding]];
    STAssertNil(responseDictionary, @"passing XML with missing markup termination to parseXMLData: should return nil");        
    
    responseDictionary = [self.metadataFileParser parseXMLData:[@"<startsand" dataUsingEncoding:NSUTF8StringEncoding]];
    STAssertNil(responseDictionary, @"passing non XML string to parseXMLData: should return nil");    
}

@end
