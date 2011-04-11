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
#import "KNFBXPSConstants.h"

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
    return 0;
    //return nil;
}

@end
