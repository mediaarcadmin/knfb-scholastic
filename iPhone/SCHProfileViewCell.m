//
//  SCHProfileViewCell.m
//  Scholastic
//
//  Created by Gordon Christie on 15/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHProfileViewCell.h"

static const CGFloat kProfileViewCellButtonWidth = 283.0f;

@implementation SCHProfileViewCell

@synthesize cellButton;
@synthesize indexPath;
@synthesize delegate;

- (void)dealloc
{
    [cellButton release], cellButton = nil;
    [indexPath release], indexPath = nil;
    delegate = nil;
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        UIImage *bgImage = [UIImage imageNamed:@"button-blue"];
        UIImage *cellBGImage = [bgImage stretchableImageWithLeftCapWidth:16 topCapHeight:0];
        CGRect buttonFrame = CGRectMake(ceilf((CGRectGetWidth(self.contentView.bounds) - kProfileViewCellButtonWidth) / 2.0f), ceilf((CGRectGetHeight(self.contentView.bounds) - bgImage.size.height) / 2.0f), kProfileViewCellButtonWidth, bgImage.size.height);
        
        cellButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [cellButton setBackgroundImage:cellBGImage forState:UIControlStateNormal];
        [cellButton setFrame:buttonFrame];
        [cellButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
        [cellButton addTarget:self action:@selector(pressed:) forControlEvents:UIControlEventTouchUpInside];
        
        cellButton.titleLabel.font = [UIFont boldSystemFontOfSize:20];
        cellButton.titleLabel.minimumFontSize = 14;
        cellButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        cellButton.titleLabel.textColor = [UIColor whiteColor];
        cellButton.titleLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.5F];
        cellButton.titleLabel.shadowOffset = CGSizeMake(0, -1);
        cellButton.titleLabel.textAlignment = UITextAlignmentCenter;
         
        [self.contentView addSubview:cellButton];

        self.selectionStyle = UITableViewCellSelectionStyleNone;

    }
    return self;
}

- (void)pressed:(id)sender
{
    [self.delegate tableView:nil didSelectRowAtIndexPath:self.indexPath];
}

@end
