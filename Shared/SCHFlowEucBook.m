//
//  SCHFlowEucBook.m
//  Scholastic
//
//  Created by Gordon Christie on 31/03/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHFlowEucBook.h"
#import "SCHBookManager.h"
#import "SCHTextFlow.h"
#import "SCHAppBook.h"
#import "SCHXPSProvider.h"
#import "SCHBookPoint.h"
#import "SCHTextFlowParagraphSource.h"
#import "KNFBXPSConstants.h"
#import <libEucalyptus/EucBookPageIndexPoint.h>

@interface SCHFlowEucBook ()

@property (nonatomic, assign) NSString *isbn;

@end

@implementation SCHFlowEucBook

@synthesize isbn;

- (id)initWithISBN:(NSString *)newIsbn
{
    SCHBookManager *bookManager = [SCHBookManager sharedBookManager];
    SCHAppBook *book = [bookManager bookWithIdentifier:newIsbn];

    if (book && (self = [super init])) {
        self.isbn = newIsbn;
        self.textFlow = [[SCHBookManager sharedBookManager] checkOutTextFlowForBookIdentifier:newIsbn];
        self.fakeCover = self.textFlow.flowTreeKind == KNFBTextFlowFlowTreeKindFlow;
        
        SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:newIsbn];
        self.title = [book XPSTitle];
        self.author = [book XPSAuthor];
        
        self.cacheDirectoryPath = [book libEucalyptusCache];
    }
    
    return self;
}

- (void)dealloc
{
    [[SCHBookManager sharedBookManager] checkInTextFlowForBookIdentifier:self.isbn];
    self.isbn = nil;
    
    [super dealloc];
}


- (NSData *)dataForURL:(NSURL *)url
{
    if([[url absoluteString] isEqualToString:@"textflow:coverimage"]) {
        SCHXPSProvider *xpsProvider = [[SCHBookManager sharedBookManager] checkOutXPSProviderForBookIdentifier:self.isbn];
        NSData *coverData = [xpsProvider coverThumbData];
        [[SCHBookManager sharedBookManager] checkInXPSProviderForBookIdentifier:self.isbn];
        return coverData;
    } else if([[url scheme] isEqualToString:@"textflow"]) {
		NSString *componentPath = [[url absoluteURL] path];
		NSString *relativePath = [url relativeString];		
		if ([relativePath length] && ([relativePath characterAtIndex:0] != '/')) {
			componentPath = [KNFBXPSEncryptedTextFlowDir stringByAppendingPathComponent:relativePath];
		}
		
        SCHXPSProvider *xpsProvider = [[SCHBookManager sharedBookManager] checkOutXPSProviderForBookIdentifier:self.isbn];
        NSData *ret = [xpsProvider dataForComponentAtPath:componentPath];
        [[SCHBookManager sharedBookManager] checkInXPSProviderForBookIdentifier:self.isbn];
        return ret;
    }
    return [super dataForURL:url];
}

-(EucBookPageIndexPoint *)indexPointForPage:(NSUInteger)page 
{
    SCHBookPoint *point = [[[SCHBookPoint alloc] init] autorelease];
    point.layoutPage = page;
    return [self bookPageIndexPointFromBookPoint:point];
}

- (EucBookPageIndexPoint *)bookPageIndexPointFromBookPoint:(SCHBookPoint *)bookPoint
{
    if(!bookPoint) {
        return nil;   
    } else {
        EucBookPageIndexPoint *eucIndexPoint = [[EucBookPageIndexPoint alloc] init];
        
        NSIndexPath *paragraphID = nil;
        uint32_t wordOffset = 0;
        
        SCHBookManager *bookManager = [SCHBookManager sharedBookManager];
        SCHTextFlowParagraphSource *paragraphSource = [bookManager checkOutParagraphSourceForBookIdentifier:self.isbn];
        [paragraphSource bookmarkPoint:bookPoint
                         toParagraphID:&paragraphID 
                            wordOffset:&wordOffset];
        [bookManager checkInParagraphSourceForBookIdentifier:self.isbn];
        
        eucIndexPoint.source = [paragraphID indexAtPosition:0];
        eucIndexPoint.block = [EucCSSIntermediateDocument keyForDocumentTreeNodeKey:[paragraphID indexAtPosition:1]];
        eucIndexPoint.word = wordOffset;
        eucIndexPoint.element = bookPoint.elementOffset;
        
        if (self.fakeCover) {
            eucIndexPoint.source++;
        }        
        
        // EucIndexPoint words start with word 0 == before the first word,
        // but Blio thinks that the first word is at 0.  This is a bit lossy,
        // but there's not much else we can do.    
        eucIndexPoint.word += 1;
        
        return [eucIndexPoint autorelease];  
    }
}

@end
