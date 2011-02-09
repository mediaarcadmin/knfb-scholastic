//
//  SCHTopFavoritesComponent.m
//  Scholastic
//
//  Created by John S. Eddie on 13/01/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHTopFavoritesComponent.h"
#import "SCHComponentProtected.h"

#import "NSNumber+ObjectTypes.h"

static NSInteger const kSCHTopFavoritesComponentTopCount = 10;
static NSString * const kSCHTopFavoritesComponentYoungReader = @"Young Reader";
static NSString * const kSCHTopFavoritesComponentAdvanced = @"Advanced Reader";

@implementation SCHTopFavoritesComponent

- (BOOL)listFavoriteTypes
{
	BOOL ret = YES;
		
	if ([self.libreAccessWebService listFavoriteTypes] == NO) {
		[[SCHAuthenticationManager sharedAuthenticationManager] authenticate];				
		ret = NO;
	}
	
	return(ret);
}

- (BOOL)topFavorites
{
	BOOL ret = YES;
	
	NSMutableDictionary *favoriteItem = [NSMutableDictionary dictionary];
	[favoriteItem setObject:[NSNumber numberWithBool:NO] forKey:kSCHLibreAccessWebServiceAssignedBooksOnly];
	[favoriteItem setObject:[NSNumber numberWithTopFavoritesType:TopFavoritesTypeseReaderCategory] forKey:kSCHLibreAccessWebServiceTopFavoritesType];
	[favoriteItem setObject:kSCHTopFavoritesComponentYoungReader forKey:kSCHLibreAccessWebServiceTopFavoritesTypeValue];
	
	if ([self.libreAccessWebService listTopFavorites:[NSArray arrayWithObject:favoriteItem] withCount:kSCHTopFavoritesComponentTopCount] == NO) {
		[[SCHAuthenticationManager sharedAuthenticationManager] authenticate];				
		ret = NO;
	}
	
	return(ret);
}

// TODO: we need clarification about how this should work to complete
- (void)method:(NSString *)method didCompleteWithResult:(NSDictionary *)result
{	
	NSLog(@"%@\n%@", method, result);
	
	if([method compare:kSCHLibreAccessWebServiceListFavoriteTypes] == NSOrderedSame) {
		// TODO: something with this
	} else if([method compare:kSCHLibreAccessWebServiceListTopFavorites] == NSOrderedSame) {
		NSArray *favorites = [self makeNullNil:[result objectForKey:kSCHLibreAccessWebServiceTopFavoritesList]];
		NSArray *books = [self makeNullNil:[[favorites objectAtIndex:0] objectForKey:kSCHLibreAccessWebServiceTopFavoritesContentItems]];
		
		if ([books count] > 0) {
			[self.libreAccessWebService listContentMetadata:books includeURLs:YES];			
		}
	} else if([method compare:kSCHLibreAccessWebServiceListContentMetadata] == NSOrderedSame) {
		// TODO: something with this
	}
}

- (void)method:(NSString *)method didFailWithError:(NSError *)error
{
	NSLog(@"%@\n%@", method, error);	
}

@end
