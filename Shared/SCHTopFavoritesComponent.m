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
static NSString * const kSCHTopFavoritesComponentCategoryPictureBooks = @"Picture books";
static NSString * const kSCHTopFavoritesComponentCategoryLevelReader = @"Level reader";
static NSString * const kSCHTopFavoritesComponentCategoryChapterBooks = @"Chapter books";
static NSString * const kSCHTopFavoritesComponentCategoryYoungAdults = @"Young Adults";

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

- (BOOL)topFavoritesForAge:(NSUInteger)ageInYears
{
	BOOL ret = YES;
    
	NSLog(@"Requesting favorite books for %u year old.", ageInYears);
	
	NSMutableDictionary *favoriteItem = [NSMutableDictionary dictionary];
	[favoriteItem setObject:[NSNumber numberWithBool:NO] forKey:kSCHLibreAccessWebServiceAssignedBooksOnly];
	[favoriteItem setObject:[NSNumber numberWithTopFavoritesType:kSCHTopFavoritesTypeseReaderCategoryClass] forKey:kSCHLibreAccessWebServiceTopFavoritesType];

    if (ageInYears < 7) {
        [favoriteItem setObject:kSCHTopFavoritesComponentCategoryPictureBooks forKey:kSCHLibreAccessWebServiceTopFavoritesTypeValue];        
    }
    else if (ageInYears < 9) {
        [favoriteItem setObject:kSCHTopFavoritesComponentCategoryLevelReader forKey:kSCHLibreAccessWebServiceTopFavoritesTypeValue];        
    }
    else if (ageInYears < 12) {
        [favoriteItem setObject:kSCHTopFavoritesComponentCategoryChapterBooks forKey:kSCHLibreAccessWebServiceTopFavoritesTypeValue];        
    } else {
        [favoriteItem setObject:kSCHTopFavoritesComponentCategoryYoungAdults forKey:kSCHLibreAccessWebServiceTopFavoritesTypeValue];        
    }
	
	if ([self.libreAccessWebService listTopFavorites:[NSArray arrayWithObject:favoriteItem] withCount:kSCHTopFavoritesComponentTopCount] == NO) {
		[[SCHAuthenticationManager sharedAuthenticationManager] authenticate];				
		ret = NO;
	}
	
	return(ret);
}

- (void)method:(NSString *)method didCompleteWithResult:(NSDictionary *)result
{	
	if([method compare:kSCHLibreAccessWebServiceListFavoriteTypes] == NSOrderedSame) {
		if([(id)self.delegate respondsToSelector:@selector(component:didCompleteWithResult:)]) {
			[(id)self.delegate component:self didCompleteWithResult:result];									
		}
	} else if([method compare:kSCHLibreAccessWebServiceListTopFavorites] == NSOrderedSame) {
		NSArray *favorites = [self makeNullNil:[result objectForKey:kSCHLibreAccessWebServiceTopFavoritesList]];
		NSArray *books = [self makeNullNil:[[favorites objectAtIndex:0] objectForKey:kSCHLibreAccessWebServiceTopFavoritesContentItems]];
		
		if ([books count] > 0) {
			[self.libreAccessWebService listContentMetadata:books includeURLs:YES];			
		} else if([(id)self.delegate respondsToSelector:@selector(component:didCompleteWithResult:)]) {
				[(id)self.delegate component:self didCompleteWithResult:[NSDictionary dictionaryWithObject:[NSNull null] forKey:kSCHLibreAccessWebServiceContentMetadataList]];									
		}
	} else if([method compare:kSCHLibreAccessWebServiceListContentMetadata] == NSOrderedSame) {
		if([(id)self.delegate respondsToSelector:@selector(component:didCompleteWithResult:)]) {
			[(id)self.delegate component:self didCompleteWithResult:result];									
		}		
	}
}

@end
