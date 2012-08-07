//
//  SCHBSBManifest.m
//  Scholastic
//
//  Created by Matt Farrugia on 10/05/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHBSBManifest.h"
#import "SCHBSBNode.h"
#import "SCHBSBConstants.h"

NSString * const SCHBSBManifestMetadataAuthorKey = @"author";
NSString * const SCHBSBManifestMetadataTitleKey = @"title";

@interface SCHBSBManifest() <NSXMLParserDelegate>

@property (nonatomic, retain) NSMutableDictionary *metadata;
@property (nonatomic, retain) NSMutableArray *nodes;
@property (nonatomic, retain) NSMutableString *currentParsedString;

@end

@implementation SCHBSBManifest

@synthesize metadata;
@synthesize nodes;
@synthesize currentParsedString;

- (void)dealloc
{
    [metadata release], metadata = nil;
    [nodes release], nodes = nil;
    [currentParsedString release], currentParsedString = nil;
    
    [super dealloc];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    if ([elementName isEqualToString:@"node"]) {
        NSString *idAttr  = [attributeDict objectForKey:@"id"];
        NSString *uriAttr = [attributeDict objectForKey:@"uri"];
        
        if (idAttr && uriAttr) {
            SCHBSBNode *node = [[SCHBSBNode alloc] init];
            node.nodeId = idAttr;
            node.uri = uriAttr;
            
            [(NSMutableArray *)self.nodes addObject:node];
            
            [node release];
        }
    }
    
    self.currentParsedString = nil;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (!self.currentParsedString) {
        self.currentParsedString = [[[NSMutableString alloc] initWithCapacity:50] autorelease];
    }
    
    [self.currentParsedString appendString:string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
    if ([elementName isEqualToString:@"title"] ) {
        if ([self.currentParsedString length]) {
            [self.metadata setValue:self.currentParsedString forKey:SCHBSBManifestMetadataTitleKey];
        }
    } else if ([elementName isEqualToString:@"author"] ) {
        if ([self.currentParsedString length]) {
            [self.metadata setValue:self.currentParsedString forKey:SCHBSBManifestMetadataAuthorKey];
        }
    }
    
    self.currentParsedString = nil;
}

- (id)initWithXMLData:(NSData *)data
{
    if ((self = [super init])) {
        
        metadata = [[NSMutableDictionary alloc] init];
        nodes = [[NSMutableArray alloc] init];
        
        NSXMLParser *manifestParser = [[NSXMLParser alloc] initWithData:data];
        [manifestParser setDelegate:self];
        [manifestParser parse];
        [manifestParser release];
    }
    
    return self;
}

@end
