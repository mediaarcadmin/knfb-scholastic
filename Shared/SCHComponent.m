//
//  SCHSyncComponent.m
//  Scholastic
//
//  Created by John S. Eddie on 04/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHComponent.h"
#import "SCHComponentProtected.h"

@implementation SCHComponent

@synthesize delegate;
@synthesize libreAccessWebService;

#pragma mark - Object lifecycle

- (id)init
{
	self = [super init];
	if (self != nil) {
		libreAccessWebService = [[SCHLibreAccessWebService alloc] init];	
		libreAccessWebService.delegate = self;
	}
	
	return(self);
}

- (void)dealloc
{	
    libreAccessWebService.delegate = nil;
	[libreAccessWebService release], libreAccessWebService = nil;
	
	[super dealloc];
}

- (void)clear
{
    self.libreAccessWebService.delegate = nil;
    self.libreAccessWebService = [[[SCHLibreAccessWebService alloc] init] autorelease];	
    self.libreAccessWebService.delegate = self;    
}

#pragma mark - Delegate methods

- (void)method:(NSString *)method didCompleteWithResult:(NSDictionary *)result
{	
	if([(id)self.delegate respondsToSelector:@selector(component:didCompleteWithResult:)]) {
		[(id)self.delegate component:self didCompleteWithResult:nil];		
	}	
}

- (void)method:(NSString *)method didFailWithError:(NSError *)error requestInfo:(NSDictionary *)requestInfo
{
	NSLog(@"%@\n%@", method, error);
	
	if([(id)self.delegate respondsToSelector:@selector(component:didFailWithError:)]) {
		[(id)self.delegate component:self didFailWithError:error];		
	}
}

#pragma mark - Private methods

- (id)makeNullNil:(id)object
{
	return(object == [NSNull null] ? nil : object);
}

@end
