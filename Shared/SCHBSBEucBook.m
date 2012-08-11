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
#import "SCHBookIdentifier.h"
#import "SCHBookManager.h"
#import "SCHAppBook.h"
#import "SCHBookPoint.h"
#import "SCHBSBPageContentsViewSpirit.h"
#import "SCHBSBManifest.h"
#import "SCHBSBNode.h"
#import "SCHBSBTree.h"
#import "SCHBSBReplacedElementPlaceholder.h"
#import "SCHBSBReplacedRadioElement.h"
#import <libEucalyptus/EucPageLayoutController.h>
#import <libEucalyptus/EucCSSIntermediateDocument.h>
#import <libEucalyptus/EucCSSIntermediateDocumentNode.h>
#import <libEucalyptus/THEmbeddedResourceManager.h>
#import <libEucalyptus/THNSURLAdditions.h>

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
        
            id <EucCSSDocumentTree> docTree = [[[SCHBSBTree alloc] initWithData:xmlData] autorelease];
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
#if 0
- (UIView *)viewForNode:(SCHBSBTreeNode *)node constrainedToSize:(CGSize)constrainedSize
{
    UIView *view = nil;
    CGRect constrainedFrame = CGRectZero;
    constrainedFrame.size = constrainedSize;
    
    NSString *dataType = [node attributeWithName:@"data-type"];
    
    if ([dataType isEqualToString:@"text"]) {
        SCHBSBPageContentsViewSpiritTextField *aTextField = [[SCHBSBPageContentsViewSpiritTextField alloc] initWithFrame:constrainedFrame];
        aTextField.frame = constrainedFrame;
        aTextField.borderStyle = UITextBorderStyleRoundedRect;
        view = [aTextField autorelease];
    } else if ([dataType isEqualToString:@"radio"]) {
        SCHBSBPageContentsViewSpiritWebView *radio = [[SCHBSBPageContentsViewSpiritWebView alloc] init];
        
        NSString *dataBinding = [node attributeWithName:@"data-binding"];
        
        NSMutableString *htmlString = [NSMutableString stringWithString:@"<body><form>"];
        
        SCHBSBTreeNode *childNode = node.firstChild;
        
        while (childNode != nil) {
            NSString *dataKey = [childNode attributeWithName:@"data-key"];
            NSString *dataValue = [childNode attributeWithName:@"data-value"];
            
            if (dataKey && dataValue) {
                [htmlString appendFormat:@"<input type='radio' name='%@' value='%@' /> %@<br />", dataBinding, dataValue, dataKey];
            }
            
            childNode = childNode.nextSibling;
        }
        
        [htmlString appendString:@"</form></body>"];
        
        [radio synchronouslyLoadHTMLString:htmlString baseURL:nil];
        radio.frame = constrainedFrame;
        view = radio;
    } else if ([dataType isEqualToString:@"dropdown"]) {
        SCHBSBPageContentsViewSpiritWebView *dropdown = [[SCHBSBPageContentsViewSpiritWebView alloc] init];
        NSString *dataBinding = [node attributeWithName:@"data-binding"];
        
        NSMutableString *htmlString = [NSMutableString stringWithFormat:@"<body><form><select name='%@'>", dataBinding];
        
        SCHBSBTreeNode *childNode = node.firstChild;
        
        while (childNode != nil) {
            NSString *dataKey = [childNode attributeWithName:@"data-key"];
            NSString *dataValue = [childNode attributeWithName:@"data-value"];
            
            if (dataKey && dataValue) {
                [htmlString appendFormat:@"<option value='%@'>%@</option>", dataValue, dataKey];
            }
            
            childNode = childNode.nextSibling;
        }
        
        [htmlString appendString:@"</select></form></body>"];
        
        [dropdown synchronouslyLoadHTMLString:htmlString baseURL:nil];
        dropdown.frame = constrainedFrame;
        view = dropdown;
    } else {
        UIButton *aButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        aButton.frame = constrainedFrame;
        [aButton setTitle:@"Hello World" forState:UIControlStateNormal];
        view = aButton;
    }
    
    return view;
}
#endif
- (id<EucCSSReplacedElement>)eucCSSIntermediateDocument:(EucCSSIntermediateDocument *)document
                                 replacedElementForNode:(EucCSSIntermediateDocumentNode *)node
{

    SCHBSBReplacedElementPlaceholder *replacedElement = nil;
    id<EucCSSDocumentTreeNode> treeNode = [(EucCSSIntermediateDocumentNode *)node documentTreeNode];
    if(treeNode) {
        NSString *dataType = [treeNode attributeWithName:@"data-type"];
        if ([dataType isEqualToString:@"text"]) {
            replacedElement = [[[SCHBSBReplacedElementPlaceholder alloc] initWithPointSize:10] autorelease];
        } else if ([dataType isEqualToString:@"radio"]) {
            NSArray *keys = [NSArray arrayWithObjects:@"alpha", @"beta", @"gamma", nil];
            NSArray *values = [NSArray arrayWithObjects:@"alpha", @"beta", @"gamma", nil];
            replacedElement = [[[SCHBSBReplacedRadioElement alloc] initWithPointSize:10 keys:keys values:values] autorelease];
        } else if ([dataType isEqualToString:@"dropdown"]) {
            replacedElement = [[[SCHBSBReplacedElementPlaceholder alloc] initWithPointSize:10] autorelease];
        }
            
    }
    
    return replacedElement;
}
                                       
@end

#endif