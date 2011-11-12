//
//  SCHAppContentProfileItem.h
//  Scholastic
//
//  Created by John S. Eddie on 18/03/2011.
//  Copyright (c) 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SCHProfileItem;
@class SCHContentProfileItem;
@class SCHBookIdentifier;

// Constants
extern NSString * const kSCHAppContentProfileItem;

extern NSString * const kSCHAppContentProfileItemDRMQualifier;
extern NSString * const kSCHAppContentProfileItemISBN;
extern NSString * const kSCHAppContentProfileItemOrder;

@interface SCHAppContentProfileItem : NSManagedObject {

}
@property (nonatomic, retain) NSNumber * DRMQualifier;
@property (nonatomic, retain) NSString * ISBN;
@property (nonatomic, retain) NSNumber * IsNewBook;
@property (nonatomic, retain) NSNumber * Order;
@property (nonatomic, retain) NSDate * LastBookmarkAnnotationSync;
@property (nonatomic, retain) NSDate * LastHighlightAnnotationSync;
@property (nonatomic, retain) NSDate * LastNoteAnnotationSync;
@property (nonatomic, retain) SCHProfileItem * ProfileItem;
@property (nonatomic, retain) SCHContentProfileItem * ContentProfileItem;

@property (nonatomic, readonly) SCHBookIdentifier *bookIdentifier;

@end
