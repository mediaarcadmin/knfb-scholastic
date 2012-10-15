//
//  SCHUpdateBooksTableViewCellController.h
//  Scholastic
//
//  Created by Neil Gall on 25/07/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SCHGradientView;
@class SCHCheckbox;
@class SCHBookIdentifier;
@class SCHUpdateBooksTableViewCell;

extern NSString * const kSCHBookUpdatedSuccessfullyNotification;

@interface SCHUpdateBooksTableViewCellController : NSObject {}

@property (nonatomic, retain) IBOutlet SCHUpdateBooksTableViewCell *cell;

- (id)initWithBookIdentifier:(SCHBookIdentifier *)bookIdentifier inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

- (void)startUpdate;

@end
