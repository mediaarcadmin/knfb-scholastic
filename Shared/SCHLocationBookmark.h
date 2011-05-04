//
//  SCHLocationBookmark.h
//  Scholastic
//
//  Created by John S. Eddie on 04/05/2011.
//  Copyright (c) 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SCHBookmark;

static NSString * const kSCHLocationBookmark = @"SCHLocationBookmark";

@interface SCHLocationBookmark : NSManagedObject 
{
}

@property (nonatomic, retain) NSNumber * Page;
@property (nonatomic, retain) SCHBookmark * Bookmark;

@end
