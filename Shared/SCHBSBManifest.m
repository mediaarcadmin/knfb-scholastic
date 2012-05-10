//
//  SCHBSBManifest.m
//  Scholastic
//
//  Created by Matt Farrugia on 10/05/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHBSBManifest.h"
#import "SCHBSBNode.h"
@interface SCHBSBManifest() <NSXMLParserDelegate>

@property (nonatomic, retain) NSMutableDictionary *metadata;
@property (nonatomic, retain) NSMutableArray *nodes;

@end

@implementation SCHBSBManifest

@synthesize metadata;
@synthesize nodes;

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
