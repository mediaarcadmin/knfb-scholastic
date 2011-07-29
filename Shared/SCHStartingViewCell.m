//
//  SCHStartingViewCell.m
//  Scholastic
//
//  Created by Neil Gall on 29/07/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStartingViewCell.h"

enum {
    kCellButtonWidth_iPad = 400,
    kCellButtonWidth_iPhone = 280,
    kCellButtonTag = 1234
};

@implementation SCHStartingViewCell

@synthesize indexPath;
@synthesize delegate;

- (void)dealloc
{
    [indexPath release], indexPath = nil;
    delegate = nil;
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    const BOOL iPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIImage *cellBGImage = [[UIImage imageNamed:@"button-blue"] stretchableImageWithLeftCapWidth:15 topCapHeight:0];
        CGFloat cellButtonWidth = iPad ? kCellButtonWidth_iPad : kCellButtonWidth_iPhone;
        CGRect buttonFrame = CGRectMake(ceilf((CGRectGetWidth(self.contentView.bounds) - cellButtonWidth) / 2.0f), 
                                        ceilf((CGRectGetHeight(self.contentView.bounds) - cellBGImage.size.height) / 2.0f), 
                                        cellButtonWidth, 
                                        cellBGImage.size.height);
        
        UIButton *cellButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [cellButton setBackgroundImage:cellBGImage forState:UIControlStateNormal];
        cellButton.backgroundColor = [UIColor clearColor];
        [cellButton setFrame:buttonFrame];
        [cellButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
        [cellButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [cellButton setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.5f] forState:UIControlStateNormal];
        cellButton.titleLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:iPad ? 26.0f : 20.0f];
        cellButton.titleLabel.shadowOffset = CGSizeMake(0, -1);
        cellButton.titleLabel.minimumFontSize = 14;
        cellButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        cellButton.titleLabel.textAlignment = UITextAlignmentCenter;
        cellButton.tag = kCellButtonTag;
        
        [cellButton addTarget:self action:@selector(tapped:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.contentView addSubview:cellButton];
    }
    return self;
}

- (void)setTitle:(NSString *)title
{
    UIButton *button = (UIButton *)[self.contentView viewWithTag:kCellButtonTag];
    [button setTitle:title forState:UIControlStateNormal];
}

- (void)tapped:(id)sender
{
    [self.delegate cellButtonTapped:self.indexPath];
}

@end
