//
//  SCHProfileViewCell.m
//  Scholastic
//
//  Created by Gordon Christie on 15/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHProfileViewCell.h"

static const CGFloat kProfileViewCellButtonWidth = 296.0f;

@implementation SCHProfileViewCell

@synthesize cellButton;
@synthesize indexPath;
@synthesize delegate;

#pragma mark - Object lifecycle

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        UIImage *bgImage = [UIImage imageNamed:@"button-blue"];
        UIImage *cellBGImage = [bgImage stretchableImageWithLeftCapWidth:15 topCapHeight:0];
        CGRect buttonFrame = CGRectMake(ceilf((CGRectGetWidth(self.contentView.bounds) - kProfileViewCellButtonWidth) / 2.0f), 
                                        ceilf((CGRectGetHeight(self.contentView.bounds) - bgImage.size.height) / 2.0f), 
                                        kProfileViewCellButtonWidth, 
                                        bgImage.size.height);
        
        cellButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [cellButton setBackgroundImage:cellBGImage forState:UIControlStateNormal];
        cellButton.backgroundColor = [UIColor clearColor];
        [cellButton setFrame:buttonFrame];
        [cellButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
        [cellButton addTarget:self 
                       action:@selector(pressed:) 
             forControlEvents:UIControlEventTouchUpInside];
        
        [cellButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [cellButton setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.5f] forState:UIControlStateNormal];

        cellButton.titleLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:26.0f];
        cellButton.titleLabel.shadowOffset = CGSizeMake(0, -1);
        cellButton.titleLabel.minimumFontSize = 14;
        cellButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        cellButton.titleLabel.textAlignment = UITextAlignmentCenter;
         
        [self.contentView addSubview:cellButton];

    }
    return(self);
}

- (void)dealloc
{
    [cellButton release], cellButton = nil;
    [indexPath release], indexPath = nil;
    delegate = nil;
    [super dealloc];
}

#pragma mark - Action methods

- (void)pressed:(id)sender
{
    [self.delegate tableView:nil didSelectRowAtIndexPath:self.indexPath];
}

@end
