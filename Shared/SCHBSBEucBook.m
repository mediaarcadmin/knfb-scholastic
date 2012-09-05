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
#import "SCHBSBReplacedElement.h"
#import "SCHBSBReplacedElementDelegate.h"
#import "SCHBSBReplacedHiddenElement.h"
#import "SCHBSBReplacedRadioElement.h"
#import "SCHBSBReplacedDropdownElement.h"
#import "SCHBSBReplacedNavigateElement.h"
#import "SCHBSBReplacedNavigateImageElement.h"
#import "SCHBSBReplacedTextElement.h"
#import <libEucalyptus/EucCSSXHTMLTree.h>
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
- (SCHBSBNode *)nodeWithName:(NSString *)name;
- (SCHBSBNode *)nodeWithUri:(NSString *)uri;
- (BOOL)validatePropertiesForNode:(SCHBSBNode *)node;
- (id<EucCSSReplacedElement>)eucCSSIntermediateDocument:(EucCSSIntermediateDocument *)document
                      replacedConditionalElementForNode:(EucCSSIntermediateDocumentNode *)node;
- (id<EucCSSReplacedElement>)eucCSSIntermediateDocument:(EucCSSIntermediateDocument *)document
                   replacedNonConditionalElementForNode:(EucCSSIntermediateDocumentNode *)node;
@end

@implementation SCHBSBEucBook

@synthesize identifier;
@synthesize managedObjectContext;
@synthesize provider;
@synthesize cacheDirectoryPath;
@synthesize manifest;
@synthesize decisionNodes;
@synthesize decisionProperties;
@synthesize delegate;

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
    delegate = nil;
     
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
            
            for (SCHBSBProperty *property in manifest.properties) {
                [decisionProperties addObject:property];
            }
            
            if ([manifest.nodes count]) {
                [decisionNodes addObject:[self.manifest.nodes objectAtIndex:0]];
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
    
    if (indexPoint.source < self.sourceCount) {
        SCHBSBNode *node = [self.decisionNodes objectAtIndex:indexPoint.source];

        if (node.uri) {
            NSData *xmlData = [self.provider dataForBSBComponentAtPath:node.uri];
            
            if ([xmlData length]) {
                NSURL *docURL = [NSURL URLWithString:[[NSString stringWithFormat:@"bsb://%@", self.identifier] stringByAppendingPathComponent:node.uri]];
                
                EucCSSXHTMLTree *docTree = [[[EucCSSXHTMLTree alloc] initWithData:xmlData] autorelease];
                doc = [[EucCSSHTMLIntermediateDocument alloc] initWithDocumentTree:docTree
                                                                            forURL:docURL
                                                                       pageOptions:pageOptions
                                                                        dataSource:self];
                
                EucCSSIntermediateDocumentNode *rootNode = [doc rootNode];
                id<EucCSSDocumentTreeNode> htmlNode = [rootNode documentTreeNode];
                id<EucCSSDocumentTreeNode> propertiesNode = [htmlNode firstChild];
                
                while (propertiesNode != nil) {
                    if ([[propertiesNode name] isEqualToString:@"properties"]) {
                        id<EucCSSDocumentTreeNode> propertyNode = [propertiesNode firstChild];
                        while (propertyNode != nil) {
                            NSString *propertyName = [propertyNode name];
                            if ([propertyName isEqualToString:@"property"]) {
                                NSMutableArray *values = [NSMutableArray array];
                                id<EucCSSDocumentTreeNode> valueNode = [propertyNode firstChild];
                                while (valueNode != nil) {
                                    NSString *valueName = [valueNode name];
                                    if ([valueName isEqualToString:@"value"]) {
                                        NSString *chance = [valueNode attributeWithName:@"chance"];
                                        NSString *value = [valueNode attributeWithName:@"value"];
                                        
                                        if (chance && value) {
                                            // FIXME: This is just equal chance at the moment
                                            [values addObject:value];
                                        }
                                    }
                                    valueNode = valueNode.nextSibling;
                                }
                                
                                NSUInteger randomIndex = rand()%[values count];
                                if ([values count] > randomIndex) {
                                    NSString *decision = [values objectAtIndex:randomIndex];
                                    NSString *name = [propertyNode attributeWithName:@"name"];
                                    if (name && decision) {
                                        SCHBSBProperty *property = [self propertyWithName:name];
                                        property.value = decision;
                                    }
                                }
                            }
                            
                            propertyNode = propertyNode.nextSibling;
                        }
                    }
                    propertiesNode = propertiesNode.nextSibling;
                }
                    
            } else {
                NSLog(@"Warning: No data at path: %@", node.uri);
            }
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
    
    return [indexPoint autorelease];
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
        if(i != 0) {
            // Nodes after the first one should always start on the left hand
            // side.
            nodePoint.placement = EucBookIndexPointPlacementLeftPage;
        }
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
    NSString *nodeBlockOverride = @"node { display: block; } select { display: block; page-break-before: avoid; } *[visible-if=\"Gender = 'boy'\"] { display: none }";
    
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

- (NSString *)eucCSSIntermediateDocument:(EucCSSIntermediateDocument *)document
                 replacedTextForTextNode:(EucCSSIntermediateDocumentNode *)node
{
    NSString *text = [node treeNodeText];
    NSMutableString *replacementText = [NSMutableString stringWithCapacity:[text length]];
    NSScanner *propertyScanner = [NSScanner scannerWithString:text];
    [propertyScanner setCharactersToBeSkipped:nil];
    
    while ([propertyScanner isAtEnd] == NO) {
        
        NSString *priorString = nil;
        NSString *propertyString = nil;
        [propertyScanner scanUpToString:@"[$" intoString:&priorString];
        [propertyScanner scanString:@"[$" intoString:nil];
        [propertyScanner scanUpToString:@"$]" intoString:&propertyString];
        [propertyScanner scanString:@"$]" intoString:nil];
        
        if (priorString) {
            [replacementText appendString:priorString];
        }
        
        if (propertyString) {
            SCHBSBProperty *property = [self propertyWithName:propertyString];
            if (property.value) {
                [replacementText appendString:property.value];
            }
        }
    }
    
//    if (![text isEqualToString:replacementText]) {
//        NSLog(@"text: %@\nreplacement: %@", text, replacementText);
//    }
    
    return replacementText;
}

- (id<EucCSSReplacedElement>)eucCSSIntermediateDocument:(EucCSSIntermediateDocument *)document
                                 replacedElementForNode:(EucCSSIntermediateDocumentNode *)node
{

    //return [self eucCSSIntermediateDocument:document replacedNonConditionalElementForNode:node];
    id<EucCSSDocumentTreeNode> treeNode = [(EucCSSIntermediateDocumentNode *)node documentTreeNode];
    if(treeNode) {
        
        NSString *conditionalAttribute = [treeNode attributeWithName:@"visible-if"];
        
        if (conditionalAttribute) {
            return [self eucCSSIntermediateDocument:document replacedConditionalElementForNode:node];
        } else {
            return [self eucCSSIntermediateDocument:document replacedNonConditionalElementForNode:node];
        }
    }
    
    return nil;
}

- (id<EucCSSReplacedElement>)eucCSSIntermediateDocument:(EucCSSIntermediateDocument *)document
                   replacedNonConditionalElementForNode:(EucCSSIntermediateDocumentNode *)node
{
    
    SCHBSBReplacedElement *replacedElement = nil;
    id<EucCSSDocumentTreeNode> treeNode = [(EucCSSIntermediateDocumentNode *)node documentTreeNode];
    if(treeNode) {
        
        NSString *nodeName = [treeNode name];
        
        if ([nodeName isEqualToString:@"input"]) {
            NSString *inputType = [treeNode attributeWithName:@"type"];
            if ([inputType isEqualToString:@"text"]) {
                NSString *dataBinding = [treeNode attributeWithName:@"name"];
                
                if (dataBinding) {
                    SCHBSBProperty *property = [self propertyWithName:dataBinding];
                    replacedElement = [[[SCHBSBReplacedTextElement alloc] initWithBinding:dataBinding value:property.value] autorelease];
                }
            } else if ([inputType isEqualToString:@"radio"]) {
                
                id<EucCSSDocumentTreeNode> radioNode    = treeNode;
                id<EucCSSDocumentTreeNode> previousNode = treeNode.previousSibling;
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
                        NSString *dataKey = [radioNode attributeWithName:@"text"];
                        NSString *dataValue = [radioNode attributeWithName:@"value"];
                    
                        if (dataKey && dataValue) {
                            [keys addObject:dataKey];
                            [values addObject:dataValue];
                        }
                    
                        radioNode = radioNode.nextSibling;
                    }
                    
                    SCHBSBProperty *property = [self propertyWithName:dataBinding];
                    replacedElement = [[[SCHBSBReplacedRadioElement alloc] initWithKeys:keys values:values binding:dataBinding value:property.value] autorelease];
                }
            }
        } else if ([nodeName isEqualToString:@"select"]) {
            NSString *dataBinding = [treeNode attributeWithName:@"name"];
            
            id<EucCSSDocumentTreeNode> childNode = treeNode.firstChild;
            NSMutableArray *keys = [NSMutableArray array];
            NSMutableArray *values = [NSMutableArray array];
            
            while (childNode != nil) {
                if ([[childNode name] isEqualToString:@"option"]) {
                    
                    NSString *dataValue = [childNode attributeWithName:@"value"];
                    id<EucCSSDocumentTreeNode> textNode = [childNode firstChild];
                    EucCSSIntermediateDocumentNode *docNode = [document nodeForKey:[EucCSSIntermediateDocument keyForDocumentTreeNodeKey:textNode.key]];
                    
                    NSString *dataString = [docNode text];
                                      
                    if (dataValue && [dataString length]) {
                        [keys addObject:dataString];
                        [values addObject:dataValue];
                    }
                }
                
                childNode = childNode.nextSibling;
            }
            
            SCHBSBProperty *property = [self propertyWithName:dataBinding];
            replacedElement = [[[SCHBSBReplacedDropdownElement alloc] initWithKeys:keys values:values binding:dataBinding value:property.value] autorelease];
        } else if ([nodeName isEqualToString:@"a"]) {
            NSString *target = [treeNode attributeWithName:@"href"];
            NSString *propertyName = [treeNode attributeWithName:@"name"];
            NSString *propertyValue = [treeNode attributeWithName:@"value"];
            
            id<EucCSSDocumentTreeNode> childNode = [treeNode firstChild];
            NSString *childName  = [childNode name];
            
            if ([childName isEqualToString:@"img"] && target) {
                NSString *src = [childNode attributeWithName:@"src"];
                if (src) {
                    NSData *imageData = [self.provider dataForBSBComponentAtPath:src];
                    UIImage *image = [UIImage imageWithData:imageData];
                    if (image) {
                        replacedElement = [[[SCHBSBReplacedNavigateImageElement alloc] initWithImage:image targetNode:target binding:propertyName value:propertyValue] autorelease];
                    }
                }
            } else {
            
                EucCSSIntermediateDocumentNode *docNode = [document nodeForKey:[EucCSSIntermediateDocument keyForDocumentTreeNodeKey:childNode.key]];
                    
                NSString *dataString = [docNode text];
                    
                if (target && [dataString length]) {
                    replacedElement = [[[SCHBSBReplacedNavigateElement alloc] initWithLabel:dataString targetNode:target binding:propertyName value:propertyValue] autorelease];
                }
            }
        }
        
        
#if SUPPORT_LEGACY_BSB_NODES
        NSString *dataType = [treeNode attributeWithName:@"data-type"];
        if ([dataType isEqualToString:@"text"]) {
            NSString *dataBinding = [treeNode attributeWithName:@"data-binding"];
            if (dataBinding) {
                SCHBSBProperty *property = [self propertyWithName:dataBinding];
                replacedElement = [[[SCHBSBReplacedTextElement alloc] initWithBinding:dataBinding value:property.value] autorelease];
            }
        } else if ([dataType isEqualToString:@"radio"]) {
            NSString *dataBinding = [treeNode attributeWithName:@"data-binding"];
            
            id<EucCSSDocumentTreeNode> childNode = treeNode.firstChild;
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

            SCHBSBProperty *property = [self propertyWithName:dataBinding];
            replacedElement = [[[SCHBSBReplacedRadioElement alloc] initWithKeys:keys values:values binding:dataBinding value:property.value] autorelease];
        } else if ([dataType isEqualToString:@"dropdown"]) {
            NSString *dataBinding = [treeNode attributeWithName:@"data-binding"];
            
            id<EucCSSDocumentTreeNode> childNode = treeNode.firstChild;
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
            
            SCHBSBProperty *property = [self propertyWithName:dataBinding];
            replacedElement = [[[SCHBSBReplacedDropdownElement alloc] initWithKeys:keys values:values binding:dataBinding value:property.value] autorelease];
        } else if ([dataType isEqualToString:@"navigate"]) {
            
            NSString *dataValue = [treeNode attributeWithName:@"data-value"];
            NSString *dataGoto = [treeNode attributeWithName:@"data-goto"];
            
            replacedElement = [[[SCHBSBReplacedNavigateElement alloc] initWithLabel:dataValue targetNode:dataGoto binding:nil value:nil] autorelease];
        }
#endif
    }
    
    if (replacedElement) {
        NSString *nodeUri = [[[document url] absoluteString] lastPathComponent];
        replacedElement.nodeId = [[self nodeWithUri:nodeUri] nodeId];
        replacedElement.delegate = self;
    }
    
    return replacedElement;
}

- (id<EucCSSReplacedElement>)eucCSSIntermediateDocument:(EucCSSIntermediateDocument *)document
                      replacedConditionalElementForNode:(EucCSSIntermediateDocumentNode *)node
{
    
    BOOL visible = NO;
    
    id<EucCSSDocumentTreeNode> treeNode = [(EucCSSIntermediateDocumentNode *)node documentTreeNode];
    if(treeNode) {
        
        NSString *conditionalAttribute = [treeNode attributeWithName:@"visible-if"];
        
        if (conditionalAttribute) {
            NSScanner *conditionalScanner = [NSScanner scannerWithString:conditionalAttribute];
            [conditionalScanner setCharactersToBeSkipped:nil];
            
            NSString *propertyString = nil;
            NSString *conditionalString = nil;
            NSString *valueString = nil;
            
            while ([conditionalScanner isAtEnd] == NO) {
                
                [conditionalScanner scanCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:nil];
                [conditionalScanner scanUpToCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:&propertyString];
                [conditionalScanner scanCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:nil];
                [conditionalScanner scanUpToCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:&conditionalString];
                [conditionalScanner scanCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:nil];
                [conditionalScanner scanString:@"'" intoString:nil];
                [conditionalScanner scanUpToString:@"'" intoString:&valueString];
                [conditionalScanner scanString:@"'" intoString:nil];
            }
            
            if ([propertyString length] &&
                [conditionalString length] &&
                [valueString length]) {
                
                SCHBSBProperty *property = [self propertyWithName:propertyString];
                if ([property value]) {
                    if ([conditionalString isEqualToString:@"=="] || [conditionalString isEqualToString:@"="]) {
                        if ([property.value caseInsensitiveCompare:valueString] == NSOrderedSame) {
                            visible = YES;
                        }
                    } else if ([conditionalString isEqualToString:@"!="]) {
                        if (![property.value caseInsensitiveCompare:valueString] != NSOrderedSame) {
                            visible = YES;
                        }
                    }
                }
                
            }
            
        }
    }

    id<EucCSSReplacedElement> replacedElement = nil;
    
    if (!visible) {
        replacedElement = [[[SCHBSBReplacedHiddenElement alloc] init] autorelease];
    } else {
        replacedElement = [self eucCSSIntermediateDocument:document replacedNonConditionalElementForNode:node];
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
        // We always assume a new property is being created on the most recently added decision node
        ret.node = [[self.decisionNodes lastObject] nodeId];
        [self.decisionProperties addObject:ret];
        [ret release];
    }
    
    return ret;
}

- (SCHBSBNode *)nodeWithName:(NSString *)name
{
    SCHBSBNode *ret = nil;
    
    for (SCHBSBNode *node in self.manifest.nodes) {
        if ([name isEqualToString:node.nodeId]) {
            ret = node;
            break;
        }
    }
    
    return ret;
}

- (SCHBSBNode *)nodeWithUri:(NSString *)uri
{
    SCHBSBNode *ret = nil;
    
    for (SCHBSBNode *node in self.manifest.nodes) {
        if ([uri isEqualToString:node.uri]) {
            ret = node;
            break;
        }
    }
    
    return ret;
}

- (BOOL)validatePropertiesForNode:(SCHBSBNode *)node
{
    NSString *nodeName = [node nodeId];
    NSIndexSet *missingIndices = [self.decisionProperties indexesOfObjectsPassingTest:^BOOL(SCHBSBProperty *property, NSUInteger idx, BOOL *stop){
        if ([[property node] isEqualToString:nodeName] && ([[property value] length] == 0)) {
            return YES;
        } else {
            return NO;
        }                    
    }];
    
    if ([missingIndices count] == 0) {
        return YES;
    } else {
        NSString *missingProps = [[[self.decisionProperties objectsAtIndexes:missingIndices] valueForKey:@"name"] componentsJoinedByString:@", "];
        NSString *message = [NSString stringWithFormat:@"Please tell us about the following, before you continue: %@.", missingProps];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
        return NO;
    }
}

- (BOOL)shouldAllowTurnBackFromIndexPoint:(EucBookPageIndexPoint *)indexPoint
{
    BOOL ret = YES;
    
    if ((indexPoint.source == 0) &&
        (indexPoint.block == 0) &&
        (indexPoint.word == 0)) {
        ret = YES;
    } else {
        EucBookPageIndexPoint *nodePoint = [[[EucBookPageIndexPoint alloc] init] autorelease];
        nodePoint.source = [self.decisionNodes count] - 1;
    
        if ([indexPoint compare:nodePoint] != NSOrderedDescending) {
            ret = NO;
        }
    }
    
    return ret;
}

#pragma mark - SCHBSBReplacedElementDelegate

- (void)binding:(NSString *)binding didUpdateValue:(NSString *)value
{
    SCHBSBProperty *property = [self propertyWithName:binding];
    property.value = value;
}

- (void)navigateToNode:(NSString *)toNodeName fromNode:(NSString *)fromNodeName;
{
    SCHBSBNode *toNode = [self nodeWithName:toNodeName];
    SCHBSBNode *fromNode = [self nodeWithName:fromNodeName];
    
    if (toNode && fromNode) {
        if ([self validatePropertiesForNode:fromNode]) {
            [self.decisionNodes addObject:toNode];
            EucBookPageIndexPoint *nodePoint = [[[EucBookPageIndexPoint alloc] init] autorelease];
            nodePoint.source = [self.decisionNodes count] - 1;
            [self.delegate book:self hasGrownToIndexPoint:nodePoint];
        }
    }
}
                                       
@end

#endif
