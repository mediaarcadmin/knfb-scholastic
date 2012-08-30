//
//  SCHBSBEucBook.m
//  Scholastic
//
//  Created by Matt Farrugia on 09/05/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//
#if !BRANCHING_STORIES_DISABLED
#import "SCHBSBEucBook.h"
#import "SCHBSBConstants.h"
#import "SCHBookPackageProvider.h"
#import "SCHBSBContentsProvider.h"
#import "SCHBookIdentifier.h"
#import "SCHBookManager.h"
#import "SCHAppBook.h"
#import "SCHBookPoint.h"
#import "SCHBSBPageContentsViewSpirit.h"
#import "SCHBSBManifest.h"
#import "SCHBSBNode.h"
#import "SCHBSBProperty.h"
#import "SCHBSBTree.h"
#import "SCHBSBTreeNode.h"
#import "SCHBSBReplacedElementPlaceholder.h"
#import "SCHBSBReplacedElementDelegate.h"
#import "SCHBSBReplacedRadioElement.h"
#import "SCHBSBReplacedDropdownElement.h"
#import "SCHBSBReplacedNavigateElement.h"
#import "SCHBSBReplacedTextElement.h"
#import <libEucalyptus/EucPageLayoutController.h>
#import <libEucalyptus/EucCSSHTMLIntermediateDocument.h>
#import <libEucalyptus/EucCSSIntermediateDocumentNode.h>
#import <libEucalyptus/THEmbeddedResourceManager.h>
#import <libEucalyptus/THNSURLAdditions.h>

#define SUPPORT_LEGACY_BSB_NODES 1

@interface SCHBSBEucBook() <EucCSSIntermediateDocumentDataProvider, SCHBSBReplacedElementDelegate>

@property (nonatomic, retain) id <SCHBookPackageProvider, SCHBSBContentsProvider> provider;
@property (nonatomic, retain) SCHBookIdentifier *identifier;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) SCHBSBManifest *manifest;
@property (nonatomic, retain) NSMutableArray *decisionNodes;
@property (nonatomic, retain) NSMutableArray *decisionProperties;

- (SCHBSBProperty *)propertyWithName:(NSString *)name;

@end

@implementation SCHBSBEucBook

@synthesize identifier;
@synthesize managedObjectContext;
@synthesize provider;
@synthesize cacheDirectoryPath;
@synthesize manifest;
@synthesize decisionNodes;
@synthesize decisionProperties;

- (void)dealloc
{
    if (provider) {
        [[SCHBookManager sharedBookManager] checkInBookPackageProviderForBookIdentifier:identifier];
        [provider release], provider = nil;
    }
    
    [identifier release], identifier = nil;
    [managedObjectContext release], managedObjectContext = nil;
    [cacheDirectoryPath release], cacheDirectoryPath = nil;
    [manifest release], manifest = nil;
    [decisionNodes release], decisionNodes = nil;
    [decisionProperties release], decisionProperties = nil;
     
    [super dealloc];
}

- (id)initWithBookIdentifier:(SCHBookIdentifier *)newIdentifier managedObjectContext:(NSManagedObjectContext *)moc
{    
    
    if ((self = [super init])) {
        SCHBookManager *bookManager = [SCHBookManager sharedBookManager];
        SCHAppBook *book = [bookManager bookWithIdentifier:newIdentifier inManagedObjectContext:moc];
        
        if (book) {
            provider = (id<SCHBookPackageProvider, SCHBSBContentsProvider>)[[[SCHBookManager sharedBookManager] checkOutBookPackageProviderForBookIdentifier:newIdentifier inManagedObjectContext:moc] retain];
            
            if (provider) {
                cacheDirectoryPath = [[book libEucalyptusCache] retain];
            }
            
            if (cacheDirectoryPath) {
                identifier = [newIdentifier retain];
            }
        }
        
        if (identifier) {
            manifest = [[provider manifest] retain];            
            decisionNodes = [[NSMutableArray alloc] init];
            decisionProperties = [[NSMutableArray alloc] init];
            
            
            if ([manifest.nodes count]) {
                [decisionNodes addObject:[manifest.nodes objectAtIndex:0]];
            
                for (SCHBSBProperty *property in manifest.properties) {
                    [decisionProperties addObject:property];
                }
            } else {
                [identifier release];
                identifier = nil;
            }
            
        }
        
        if (identifier == nil) {
            [self release];
            self = nil;
        }
    }
    
    return self;
}

- (EucCSSIntermediateDocument *)intermediateDocumentForIndexPoint:(EucBookPageIndexPoint *)indexPoint
                                                      pageOptions:(NSDictionary *)pageOptions
{
    EucCSSHTMLIntermediateDocument *doc = nil;
    SCHBSBNode *node = [self.decisionNodes objectAtIndex:indexPoint.source];
    
    if (node.uri) {
        NSData *xmlData = [self.provider dataForBSBComponentAtPath:node.uri];
        
        if ([xmlData length]) {
            NSURL *docURL = [NSURL URLWithString:[[NSString stringWithFormat:@"bsb://%@", self.identifier] stringByAppendingPathComponent:node.uri]];
            
            id <EucCSSDocumentTree> docTree = [[[SCHBSBTree alloc] initWithData:xmlData] autorelease];
            doc = [[EucCSSHTMLIntermediateDocument alloc] initWithDocumentTree:docTree
                                                                        forURL:docURL
                                                                   pageOptions:pageOptions
                                                                    dataSource:self];
        } else {
            NSLog(@"Warning: No data at path: %@", node.uri);
        }
    }
    
    return [doc autorelease];
}

- (NSUInteger)sourceCount
{
    return [self.decisionNodes count];
}

#pragma mark - EucBook

- (Class)pageLayoutControllerClass
{
    return [EucPageLayoutController class];
}

- (Class)pageContentsViewSpiritClass
{
    return [SCHBSBPageContentsViewSpirit class];
}

- (NSArray *)navPoints
{
    // Not required for BSB
    return nil;
}

- (EucBookNavPoint *)navPointWithUuid:(NSString *)uuid
{
    // Not required for BSB
    return nil;
}

- (EucBookPageIndexPoint *)indexPointForUuid:(NSString *)identifier
{
    // Not required for BSB
    return nil;
}

- (float)estimatedPercentageForIndexPoint:(EucBookPageIndexPoint *)point
{
    CGFloat estimate = 0;
    NSUInteger decisionCount = [self.decisionNodes count];
    
    if (decisionCount) {
        estimate = point.source / (CGFloat)decisionCount;
    }
    
    return estimate;
}

- (EucBookPageIndexPoint *)estimatedIndexPointForPercentage:(float)percentage
{
    percentage = MIN(percentage, 1);
    NSUInteger decisionCount = [self.decisionNodes count];
    NSUInteger source = decisionCount * percentage;
    
    EucBookPageIndexPoint *indexPoint = [[EucBookPageIndexPoint alloc] init];
    indexPoint.source = source;
    
    return indexPoint;
}

- (EucBookPageIndexPoint *)offTheEndIndexPoint
{
    EucBookPageIndexPoint *indexPoint = [[EucBookPageIndexPoint alloc] init];
    indexPoint.source = self.sourceCount;
    
    return [indexPoint autorelease];
}

- (NSArray *)hardPageBreakIndexPoints
{
    
    NSMutableArray *allNodes = [[NSMutableArray alloc] initWithCapacity:self.sourceCount];
    
    for (int i = 0; i < self.sourceCount; i++) {
        EucBookPageIndexPoint *nodePoint = [[EucBookPageIndexPoint alloc] init];
        nodePoint.source = i;
        [allNodes addObject:nodePoint];
        [nodePoint release];
    }
    
    return [allNodes autorelease];
}

- (BOOL)fullBleedPageForIndexPoint:(EucBookPageIndexPoint *)indexPoint
{
    return NO;
}

- (NSString *)stringForIndexPointRange:(EucBookPageIndexPointRange *)indexPointRange
{
    // Not required for BSB
    return nil;
}

#pragma mark - EucBookReference

- (NSString *)uniqueIdentifier
{
    // Not required for BSB
    return nil;
}

- (NSString *)title
{
    return [self.manifest.metadata valueForKey:SCHBSBManifestMetadataTitleKey];
}

- (NSString *)author
{
    return [self.manifest.metadata valueForKey:SCHBSBManifestMetadataAuthorKey];
}

- (NSData *)coverImageData
{
    // Not required for BSB
    return nil;
}

- (NSString *)humanReadableAuthor
{
    // Not required for BSB
    return nil;
}

- (NSString *)humanReadableTitle
{
    // Not required for BSB
    return nil;
}

#pragma mark - SCHEucBookmarkPointTranslation

- (SCHBookPoint *)bookPointFromBookPageIndexPoint:(EucBookPageIndexPoint *)indexPoint
{
    return nil;
}

- (EucBookPageIndexPoint *)bookPageIndexPointFromBookPoint:(SCHBookPoint *)bookPoint
{
    return nil;
}
                                       
#pragma mark - EucCSSIntermediateDocumentDataProvider

- (NSData *)dataForURL:(NSURL *)url
{
    NSString *componentPath = [url relativeString];
    
    return [self.provider dataForBSBComponentAtPath:componentPath];
}

- (NSURL *)externalURLForURL:(NSURL *)url
{
    return url;
}

- (NSArray *)userAgentCSSDatasForDocumentTree:(id<EucCSSDocumentTree>)documentTree
{
    return [NSArray arrayWithObject:[THEmbeddedResourceManager embeddedResourceWithName:@"EPubUserAgent.css"]];
}

- (NSArray *)userCSSDatasForDocumentTree:(id<EucCSSDocumentTree>)documentTree
{
    NSString *nodeBlockOverride = @"node { display: block }";
    
	return [NSArray arrayWithObjects:[THEmbeddedResourceManager embeddedResourceWithName:@"EPubOverrides.css"],
            [nodeBlockOverride dataUsingEncoding:NSUTF8StringEncoding], nil];
}

- (NSArray *)userCSSURLsForDocument:(EucCSSIntermediateDocument *)document
{
    return [[self userCSSDatasForDocumentTree:[document documentTree]] valueForKey:@"thDataURL"];
}

- (NSArray *)userAgentCSSURLsForDocument:(EucCSSIntermediateDocument *)document
{
    return [[self userAgentCSSDatasForDocumentTree:[document documentTree]] valueForKey:@"thDataURL"];
}

- (id<EucCSSReplacedElement>)eucCSSIntermediateDocument:(EucCSSIntermediateDocument *)document
                                 replacedElementForNode:(EucCSSIntermediateDocumentNode *)node
{

    SCHBSBReplacedElementPlaceholder *replacedElement = nil;
    id<EucCSSDocumentTreeNode> treeNode = [(EucCSSIntermediateDocumentNode *)node documentTreeNode];
    if(treeNode) {
        
        NSString *nodeName = [treeNode name];
        
        if ([nodeName isEqualToString:@"input"]) {
            NSString *inputType = [treeNode attributeWithName:@"type"];
            if ([inputType isEqualToString:@"text"]) {
                NSString *dataBinding = [treeNode attributeWithName:@"name"];
                
                if (dataBinding) {
                    SCHBSBProperty *property = [self propertyWithName:dataBinding];
                    replacedElement = [[[SCHBSBReplacedTextElement alloc] initWithPointSize:10 binding:dataBinding value:property.value] autorelease];
                    replacedElement.delegate = self;
                }
            } else if ([inputType isEqualToString:@"radio"]) {
                
                SCHBSBTreeNode *radioNode    = treeNode;
                SCHBSBTreeNode *previousNode = treeNode.previousSibling;
                NSString *dataBinding        = [radioNode attributeWithName:@"name"];
                NSString *previousBinding    = nil;
                
                while (previousNode != nil) {
                    if ([[previousNode name] isEqualToString:@"input"] &&
                        [[previousNode attributeWithName:@"type"] isEqualToString:@"radio"]) {
                        previousBinding = [previousNode attributeWithName:@"name"];
                    }
                    
                    if (previousBinding != nil) {
                        break;
                    }
                    previousNode = previousNode.previousSibling;
                }
                                
                if (dataBinding && ![previousBinding isEqualToString:dataBinding]) {

                    NSMutableArray *keys = [NSMutableArray array];
                    NSMutableArray *values = [NSMutableArray array];
                
                    while (radioNode != nil) {
                        NSString *dataKey = [radioNode attributeWithName:@"value"];
                        NSString *dataValue = [radioNode attributeWithName:@"text"];
                    
                        if (dataKey && dataValue) {
                            [keys addObject:dataKey];
                            [values addObject:dataValue];
                        }
                    
                        radioNode = radioNode.nextSibling;
                    }
                    
                    replacedElement = [[[SCHBSBReplacedRadioElement alloc] initWithPointSize:10 keys:keys values:values binding:dataBinding] autorelease];
                }
            }
        } else if ([nodeName isEqualToString:@"select"]) {
            NSString *dataBinding = [treeNode attributeWithName:@"name"];
            
            SCHBSBTreeNode *childNode = treeNode.firstChild;
            NSMutableArray *keys = [NSMutableArray array];
            NSMutableArray *values = [NSMutableArray array];
            
            while (childNode != nil) {
                if ([[childNode name] isEqualToString:@"option"]) {
                    
                    NSString *dataKey = [childNode attributeWithName:@"value"];                    
                    NSString *dataString = dataKey;
                                      
                    if (dataKey && [dataString length]) {
                        [keys addObject:dataKey];
                        [values addObject:dataString];
                    }
                }
                
                childNode = childNode.nextSibling;
            }
            
            replacedElement = [[[SCHBSBReplacedDropdownElement alloc] initWithPointSize:20 keys:keys values:values binding:dataBinding] autorelease];
        }
        
        
        
#if SUPPORT_LEGACY_BSB_NODES
        NSString *dataType = [treeNode attributeWithName:@"data-type"];
        if ([dataType isEqualToString:@"text"]) {
            NSString *dataBinding = [treeNode attributeWithName:@"data-binding"];
            if (dataBinding) {
                SCHBSBProperty *property = [self propertyWithName:dataBinding];
                replacedElement = [[[SCHBSBReplacedTextElement alloc] initWithPointSize:10 binding:dataBinding value:property.value] autorelease];
            }
        } else if ([dataType isEqualToString:@"radio"]) {
            NSString *dataBinding = [treeNode attributeWithName:@"data-binding"];
            
            SCHBSBTreeNode *childNode = treeNode.firstChild;
            NSMutableArray *keys = [NSMutableArray array];
            NSMutableArray *values = [NSMutableArray array];
            
            while (childNode != nil) {
                NSString *dataKey = [childNode attributeWithName:@"data-key"];
                NSString *dataValue = [childNode attributeWithName:@"data-value"];
                
                if (dataKey && dataValue) {
                    [keys addObject:dataKey];
                    [values addObject:dataValue];
                }
                
                childNode = childNode.nextSibling;
            }

            replacedElement = [[[SCHBSBReplacedRadioElement alloc] initWithPointSize:10 keys:keys values:values binding:dataBinding] autorelease];
        } else if ([dataType isEqualToString:@"dropdown"]) {
            NSString *dataBinding = [treeNode attributeWithName:@"data-binding"];
            
            SCHBSBTreeNode *childNode = treeNode.firstChild;
            NSMutableArray *keys = [NSMutableArray array];
            NSMutableArray *values = [NSMutableArray array];
            
            while (childNode != nil) {
                NSString *dataKey = [childNode attributeWithName:@"data-key"];
                NSString *dataValue = [childNode attributeWithName:@"data-value"];
                
                if (dataKey && dataValue) {
                    [keys addObject:dataKey];
                    [values addObject:dataValue];
                }
                
                childNode = childNode.nextSibling;
            }
            
            replacedElement = [[[SCHBSBReplacedDropdownElement alloc] initWithPointSize:20 keys:keys values:values binding:dataBinding] autorelease];
        } else if ([dataType isEqualToString:@"navigate"]) {
            
            NSString *dataValue = [treeNode attributeWithName:@"data-value"];
            NSString *dataGoto = [treeNode attributeWithName:@"data-goto"];
            
            replacedElement = [[[SCHBSBReplacedNavigateElement alloc] initWithPointSize:20 label:dataValue action:dataGoto] autorelease];
        }
#endif
    }
    
    return replacedElement;
}

- (SCHBSBProperty *)propertyWithName:(NSString *)name
{
    SCHBSBProperty *ret = nil;
    
    for (SCHBSBProperty *existing in self.decisionProperties) {
        if ([name isEqualToString:existing.name]) {
            ret = existing;
            break;
        }
    }
    
    if (!ret) {
        ret = [[SCHBSBProperty alloc] init];
        ret.name = name;
        [self.decisionProperties addObject:ret];
        [ret release];
    }
    
    return ret;
}

#pragma mark - SCHBSBReplacedElementDelegate

- (void)binding:(NSString *)binding didUpdateValue:(NSString *)value
{
    SCHBSBProperty *property = [self propertyWithName:binding];
    property.value = value;
}
                                       
@end

#endif