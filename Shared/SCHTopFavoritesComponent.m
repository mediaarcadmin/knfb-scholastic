//
//  SCHTopFavoritesComponent.m
//  Scholastic
//
//  Created by John S. Eddie on 13/01/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHTopFavoritesComponent.h"

static NSInteger const kSCHTopFavoritesComponentTopCount = 10;

@implementation SCHTopFavoritesComponent

- (BOOL)topFavorites
{
	BOOL ret = YES;
	self.libreAccessWebService.delegate = self;
	
//	if ([self.libreAccessWebService listFavoriteTypes] == NO) {
//		[[SCHAuthenticationManager sharedAuthenticationManager] authenticate];				
//		ret = NO;
//	}
	if ([self.libreAccessWebService listTopFavorites:kSCHTopFavoritesComponentTopCount] == NO) {
		[[SCHAuthenticationManager sharedAuthenticationManager] authenticate];				
		ret = NO;
	}
	
	return(ret);
}

- (void)method:(NSString *)method didCompleteWithResult:(NSDictionary *)result
{	
	NSLog(@"%@\n%@", method, result);
	
	if([method compare:kSCHLibreAccessWebServiceListTopFavorites] == NSOrderedSame) {
		NSArray *books = [result objectForKey:kSCHLibreAccessWebServiceTopFavoritesResponseList];
		if ([books count] > 0) {
			// collect them all
			[self.libreAccessWebService listContentMetadata:books includeURLs:YES];			
		}
	} else if([method compare:kSCHLibreAccessWebServiceListContentMetadata] == NSOrderedSame) {
		// TODO: send the books to the delegate
		//[self updateBooks:[result objectForKey:kSCHLibreAccessWebServiceContentMetadataList]];
	}
}

- (void)method:(NSString *)method didFailWithError:(NSError *)error
{
	NSLog(@"%@\n%@", method, error);	
}

@end
