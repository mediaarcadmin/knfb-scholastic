//
//  SCHBookShelfTableViewCell.h
//  Scholastic
//
//  Created by Gordon Christie on 17/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SCHBookShelfTableViewCellDelegate;

@interface SCHBookShelfTableViewCell : UITableViewCell {
}


@property (nonatomic, copy) NSString *isbn;
@property (nonatomic, assign) id <SCHBookShelfTableViewCellDelegate> delegate;

- (void) refreshCell;

@end


@protocol SCHBookShelfTableViewCellDelegate <NSObject>

@optional
- (void)bookShelfTableViewCellSelectedDeleteForISBN:(NSString *)isbn;

@end
