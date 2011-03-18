//
//  SCHAppBook.h
//  Scholastic
//
//  Created by John S. Eddie on 15/03/2011.
//  Copyright (c) 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SCHContentMetadataItem;

@interface SCHAppBook : NSManagedObject {
@private
}
@property (nonatomic, retain) SCHContentMetadataItem * ContentMetadataItem;

@end
