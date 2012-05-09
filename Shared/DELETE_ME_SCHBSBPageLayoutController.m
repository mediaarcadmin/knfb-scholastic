//
//  SCHBSBPageLayoutController.m
//  Scholastic
//
//  Created by Matt Farrugia on 09/05/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "DELETE_ME_SCHBSBPageLayoutController.h"
#import <libEucalyptus/EucBook.h>
#import <libEucalyptus/THPair.h>

@interface SCHBSBPageLayoutController()

@property (nonatomic, assign) BOOL isTwoUp;

@end

@implementation SCHBSBPageLayoutController

@synthesize book;
@synthesize pageSize;
@synthesize pointSize;
@synthesize pageOptions;
@synthesize availablePointSizes;
@synthesize pageCount;
@synthesize isTwoUp;

#pragma mark - EucPageLayoutController

- (void)dealloc
{
    [book release], book = nil;
    [pageOptions release], pageOptions = nil;
    [availablePointSizes release], availablePointSizes = nil;

    [super dealloc];
}

- (id)initWithBook:(id<EucBook>)aBook 
          pageSize:(CGSize)aPageSize
        pointSizes:(NSArray *)aPointSize
           isTwoUp:(BOOL)twoUp
       pageOptions:(NSDictionary *)aPageOptions
{
    if ((self = [super init])) {
        book = [aBook retain];
        pageSize = aPageSize;
        availablePointSizes = [aPointSize retain];
        isTwoUp = twoUp;
        pageOptions = [aPageOptions retain];
    }
    
    return self;
}

- (THPair *)viewSpiritAndIndexPointRangeForIndexPoint:(EucBookPageIndexPoint *)indexPoint atKnownPageStart:(BOOL)atPageStart
{
    return nil;
}

- (NSUInteger)pageIndexForIndexPoint:(EucBookPageIndexPoint *)indexPoint
{
    return 0;
}

- (EucBookPageIndexPointRange *)pageIndexPointRangeForPageIndex:(NSUInteger)pageIndex
{
    return nil;
}

- (EucBookPageIndexPointRange *)pageIndexPointRangeForPageEndingAtIndexPoint:(EucBookPageIndexPoint *)indexPoint
{
    return nil;
}

// A "display number" i.e. cover -> nil, 2 -> @"1" etc;
// Could also do things like convert to roman numerals when appropriate.
- (NSString *)displayPageNumberForPageIndex:(NSUInteger)pageIndex
{
    return nil;
}

// A fuller description.
// i.e. page 3 might be "1 of 300", to discount the cover and inner licence page.
// page 1 might be "Cover" etc.
- (NSString *)pageDescriptionForPageIndex:(NSUInteger)pageIndex
{
    return nil;
}

- (BOOL)pageEdgeIsRigidForPageViewSpirit:(EucPageViewSpirit *)page
{
    return NO;
}

+ (EucPageViewSpirit *)blankPageViewSpiritWithFrame:(CGRect)frame
                                       forPointSize:(CGFloat)pointSize
                                     formatForTwoUp:(BOOL)formatForTwoUp
                                        pageOptions:(NSDictionary *)pageOptions
{
    return nil;
}

+ (NSDictionary *)defaultPageOptions
{
    return nil;
}

+ (NSDictionary *)pageOptionsAffectingIndexFromPageOptions:(NSDictionary *)pageOptions
{
    return nil;
}

@end
