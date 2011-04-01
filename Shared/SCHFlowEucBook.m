//
//  SCHFlowEucBook.m
//  Scholastic
//
//  Created by Gordon Christie on 31/03/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHFlowEucBook.h"
#import "SCHBookManager.h"
#import "SCHAppBook.h"
#import "BITXPSProvider.h"

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
        self.textFlow = (KNFBTextFlow *) [bookManager checkOutTextFlowForBookIdentifier:self.isbn];
        
        self.title = book.Title;
        self.author = book.Author;
        self.etextNumber = nil;
        
        self.cacheDirectoryPath = [book cacheDirectory];
    }
    
    return self;
}

- (void)dealloc
{
    self.textFlow = nil;
    [[SCHBookManager sharedBookManager] checkInTextFlowForBookIdentifier:self.isbn];
    self.isbn = nil;
    
    [super dealloc];
}


- (NSData *)dataForURL:(NSURL *)url
{
    if([[url absoluteString] isEqualToString:@"textflow:coverimage"]) {
        BITXPSProvider *xpsProvider = [[SCHBookManager sharedBookManager] checkOutXPSProviderForBookIdentifier:self.isbn];
        NSData *coverData = [xpsProvider coverThumbData];
        [[SCHBookManager sharedBookManager] checkInXPSProviderForBookIdentifier:self.isbn];
        return coverData;
    } else if([[url scheme] isEqualToString:@"textflow"]) {
		NSString *componentPath = [[url absoluteURL] path];
		NSString *relativePath = [url relativeString];		
		if ([relativePath length] && ([relativePath characterAtIndex:0] != '/')) {
			componentPath = [BlioXPSEncryptedTextFlowDir stringByAppendingPathComponent:relativePath];
		}
		
        BITXPSProvider *xpsProvider = [[SCHBookManager sharedBookManager] checkOutXPSProviderForBookIdentifier:self.isbn];
        NSData *ret = [xpsProvider dataForComponentAtPath:componentPath];
        [[SCHBookManager sharedBookManager] checkInXPSProviderForBookIdentifier:self.isbn];
        return ret;
    }
    return [super dataForURL:url];
}

-(EucBookPageIndexPoint *)indexPointForPage:(NSUInteger)page 
{
    //[NSException raise:@"SCHFlowEucBookUnimplemented" format:@"indexPointForPage has not yet been implemented in SCHFlowEucBook."];
    return nil;
}

@end
