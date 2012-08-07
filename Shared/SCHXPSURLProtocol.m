//
//  SCHXPSURLProtocol.m
//  Scholastic
//
//  Created by Matt Farrugia on 08/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHXPSURLProtocol.h"
#import "SCHBookManager.h"
#import "SCHBookIdentifier.h"
#import "SCHXPSProvider.h"

@implementation SCHXPSURLProtocol

+ (void)registerXPSProtocol {
	static BOOL inited = NO;
	if ( ! inited ) {
		[NSURLProtocol registerClass:[SCHXPSURLProtocol class]];
		inited = YES;
	}
}

/* our own class method.  Here we return the NSString used to mark
 urls handled by our special protocol. */
+ (NSString *)xpsProtocolScheme {
	return @"storiaXpsUrlProtocol";
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
	NSString *theScheme = [[request URL] scheme];
	return (theScheme != nil &&
            [theScheme isEqualToString:[SCHXPSURLProtocol xpsProtocolScheme]] == NSOrderedSame);
}

/* if canInitWithRequest returns true, then webKit will call your
 canonicalRequestForRequest method so you have an opportunity to modify
 the NSURLRequest before processing the request */
+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

- (void)startLoading {
	
    // The hostname of the URLRequest should contain an SCHBookIdentifier encoded with its
    // -[SCHBookIdentifier encodeAsString] method.
	
	/* retrieve the current request. */
    NSURLRequest *request = [self request];
	NSString *encodedBookIdentifier = [[request URL] host];
	
	if (encodedBookIdentifier && ![encodedBookIdentifier isEqualToString:@"undefined"]) {
		CFStringRef bookISBNStringRef = CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault, (CFStringRef)encodedBookIdentifier, CFSTR(""), kCFStringEncodingUTF8);		
		encodedBookIdentifier = [NSString stringWithString:(NSString *)bookISBNStringRef];
		CFRelease(bookISBNStringRef);
	}
	
    SCHBookIdentifier *bookIdentifier = [[[SCHBookIdentifier alloc] initWithEncodedString:encodedBookIdentifier] autorelease];
    if (!bookIdentifier) {
        return;
    }
	
	SCHXPSProvider *xpsProvider = (SCHXPSProvider *)[[SCHBookManager sharedBookManager] threadSafeCheckOutBookPackageProviderForBookIdentifier:bookIdentifier];
    
    if (!xpsProvider) {
		return;
	}
	
	NSString *path = [[request URL] path];
	NSData *data = [xpsProvider dataForComponentAtPath:path];
	
	NSURLResponse *response = 
	[[NSURLResponse alloc] initWithURL:[request URL] 
							  MIMEType:nil 
				 expectedContentLength:-1 
					  textEncodingName:@"utf-8"];
	
	/* get a reference to the client so we can hand off the data */
    id<NSURLProtocolClient> client = [self client];
	
	/* turn off caching for this response data */ 
	[client URLProtocol:self didReceiveResponse:response
	 cacheStoragePolicy:NSURLCacheStorageNotAllowed];
	
	/* set the data in the response to our data */ 
	[client URLProtocol:self didLoadData:data];
	
	/* notify that we completed loading */
	[client URLProtocolDidFinishLoading:self];
	
	/* we can release our copy */
	[response release];
	
	[[SCHBookManager sharedBookManager] checkInBookPackageProviderForBookIdentifier:bookIdentifier];
	
}

- (void)stopLoading {
	// Do nothing
}

@end