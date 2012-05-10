//
//  SCHBSBEucBook.m
//  Scholastic
//
//  Created by Matt Farrugia on 09/05/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHBSBEucBook.h"
#import "SCHBSBConstants.h"
#import "SCHBookPackageProvider.h"
#import "SCHBookIdentifier.h"
#import "SCHBookManager.h"
#import "SCHAppBook.h"
#import "SCHBookPoint.h"
#import "SCHBSBPageContentsViewSpirit.h"
#import "SCHBSBManifest.h"
#import "SCHBSBNode.h"
#import <libEucalyptus/EucPageLayoutController.h>
#import <libEucalyptus/EucCSSIntermediateDocument.h>
#import <libEucalyptus/EucCSSXHTMLTree.h>
#import <libEucalyptus/THEmbeddedResourceManager.h>

@interface SCHBSBEucBook() <EucCSSIntermediateDocumentDataProvider>

@property (nonatomic, retain) id <SCHBookPackageProvider> provider;
@property (nonatomic, retain) SCHBookIdentifier *identifier;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) SCHBSBManifest *manifest;
@property (nonatomic, retain) NSMutableArray *decisionNodes;

@end

@implementation SCHBSBEucBook

@synthesize identifier;
@synthesize managedObjectContext;
@synthesize provider;
@synthesize cacheDirectoryPath;
@synthesize manifest;
@synthesize decisionNodes;

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
     
    [super dealloc];
}

- (id)initWithBookIdentifier:(SCHBookIdentifier *)newIdentifier managedObjectContext:(NSManagedObjectContext *)moc
{    
    
    if ((self = [super init])) {
        SCHBookManager *bookManager = [SCHBookManager sharedBookManager];
        SCHAppBook *book = [bookManager bookWithIdentifier:newIdentifier inManagedObjectContext:moc];
        
        if (book) {
            provider = [[[SCHBookManager sharedBookManager] checkOutBookPackageProviderForBookIdentifier:newIdentifier inManagedObjectContext:moc] retain];
            
            if (provider) {
                cacheDirectoryPath = [[book libEucalyptusCache] retain];
            }
            
            if (cacheDirectoryPath) {
                identifier = [newIdentifier retain];
            }
        }
        
        if (identifier) {
            NSData *packageData = [self.provider dataForComponentAtPath:SCHBSBManifestFile];
            manifest = [[SCHBSBManifest alloc] initWithXMLData:packageData];
            
            decisionNodes = [[NSMutableArray alloc] init];
            
            // TEMP
            for (SCHBSBNode *node in manifest.nodes) {
                [decisionNodes addObject:node];
            }
            
        } else {
            [self release];
            self = nil;
        }
    }
    
    return self;
}

- (EucCSSIntermediateDocument *)intermediateDocumentForIndexPoint:(EucBookPageIndexPoint *)indexPoint 
                                                      pageOptions:(NSDictionary *)pageOptions
{
    EucCSSIntermediateDocument *doc = nil;
    SCHBSBNode *node = [self.decisionNodes objectAtIndex:indexPoint.source];
    
    if (node.uri) {
        NSData *xmlData = [self.provider dataForComponentAtPath:node.uri];
        
        if ([xmlData length]) {
            NSURL *docURL = [NSURL URLWithString:[[NSString stringWithFormat:@"bsb://%@", self.identifier] stringByAppendingPathComponent:node.uri]];
        
            id <EucCSSDocumentTree> docTree = [[[EucCSSXHTMLTree alloc] initWithData:xmlData] autorelease];
            doc = [[EucCSSIntermediateDocument alloc] initWithDocumentTree:docTree 
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
    
    return [self.provider dataForComponentAtPath:componentPath];
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
                                       
@end
