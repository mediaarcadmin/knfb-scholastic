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

@property (nonatomic, copy) NSString *isbn;
@property (nonatomic, assign) SCHTextFlowParagraphSource *paragraphSource;

@end

@implementation SCHFlowEucBook

@synthesize isbn;
@synthesize paragraphSource;

- (id)initWithISBN:(NSString *)newIsbn
{
    SCHBookManager *bookManager = [SCHBookManager sharedBookManager];
    SCHAppBook *book = [bookManager bookWithIdentifier:newIsbn];
    
    if (book) {
        SCHTextFlow *aTextFlow = [[SCHBookManager sharedBookManager] checkOutTextFlowForBookIdentifier:newIsbn];
        BOOL aFakeCover = aTextFlow.flowTreeKind == KNFBTextFlowFlowTreeKindFlow;
        NSString *aCacheDirectoryPath = [book libEucalyptusCache];
    
        if ((self = [super initWithBookID:nil
                       cacheDirectoryPath:aCacheDirectoryPath
                                 textFlow:aTextFlow
                                fakeCover:aFakeCover])) 
        {
            isbn = [newIsbn copy];
        
                
            self.title = [book XPSTitle];
            self.author = [book XPSAuthor];        
        }
    }
    
    return self;
}

- (SCHTextFlowParagraphSource *)paragraphSource
{
    if (!paragraphSource) {
        // Rather than checking a paragraph source in and out we check it out on first use for the duration of our
        // SCHFlowEucBook. However we don't retain it to avoid a retain cycle as a xaml EucBook will have a paragraph
        // source that also checks out and retains the SCHFlowEucBook! The correct fix is for a paragraph source to not
        // retain its checked out FlowEucBook but since that property is in libKNFBReader rather than Scholastic
        // we are breaking the retain loop here. So long as the checkout mechanism also retains the paragraph source
        // it will not dealloc duing the lifetime of this object
        //
        // N.B. this must be lazily instantiated because checking it out during the init would result in a checkout cycle
        // loop if the paragraph source is 
        // being checked
        paragraphSource = [[SCHBookManager sharedBookManager] checkOutParagraphSourceForBookIdentifier:self.isbn];
    }
    
    return paragraphSource;
}

- (void)dealloc
{
    
    if (self.textFlow) {
        [[SCHBookManager sharedBookManager] checkInTextFlowForBookIdentifier:self.isbn];
    }
    
    if (paragraphSource) {
        [[SCHBookManager sharedBookManager] checkInParagraphSourceForBookIdentifier:self.isbn];
        paragraphSource = nil;
    }
    
    [isbn release], isbn = nil;
    
    [super dealloc];
}


- (NSData *)dataForURL:(NSURL *)url
{
    if([[url absoluteString] isEqualToString:@"textflow:coverimage"]) {
        NSData *coverData = [[(SCHTextFlow *)self.textFlow xpsProvider] coverThumbData];
        return coverData;
    } else if([[url scheme] isEqualToString:@"textflow"]) {
		NSString *componentPath = [[url absoluteURL] path];
		NSString *relativePath = [url relativeString];		
		if ([relativePath length] && ([relativePath characterAtIndex:0] != '/')) {
			componentPath = [KNFBXPSEncryptedTextFlowDir stringByAppendingPathComponent:relativePath];
		}
		
        NSData *ret = [[(SCHTextFlow *)self.textFlow xpsProvider] dataForComponentAtPath:componentPath];
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
        
        [self.paragraphSource bookmarkPoint:bookPoint
                         toParagraphID:&paragraphID 
                            wordOffset:&wordOffset];
        
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

-(NSArray *)hardBreakIndexPoints
{

}

-(EucBookIndexPoint *)offTheEndIndexPoint
{
    
}

@end
