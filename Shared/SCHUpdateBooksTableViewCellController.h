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
@class SCHAppBook;

extern NSString * const kSCHBookUpdatedSuccessfullyNotification;

@interface SCHUpdateBooksTableViewCellController : NSObject {}

@property (nonatomic, retain) IBOutlet UITableViewCell *cell;
@property (nonatomic, retain) IBOutlet UILabel *bookTitleLabel;
@property (nonatomic, retain) IBOutlet SCHCheckbox *enableForUpdateCheckbox;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, assign) BOOL bookEnabledForUpdate;

- (id)initWithBookObjectID:(NSManagedObjectID *)objectID inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

- (IBAction)enableForUpdateChanged:(id)sender;
- (void)startUpdateIfEnabled;

@end
