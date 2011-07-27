//
//  SCHUpdateBooksTableViewCell.m
//  Scholastic
//
//  Created by Neil Gall on 27/07/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHUpdateBooksTableViewCell.h"
#import "SCHGradientView.h"
#import "SCHCheckbox.h"

enum {
    kBookTitleLabelTag = 1,
    kBookTitleGradientTag = 2,
    kEnableForUpdateCheckboxTag = 3,
    kSpinnerTag = 4,
};

@implementation SCHUpdateBooksTableViewCell

@synthesize onCheckboxUpdate;

- (void)dealloc
{
    [onCheckboxUpdate release], onCheckboxUpdate = nil;
    [super dealloc];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        SCHGradientView *gradientView = (SCHGradientView *)[self viewWithTag:kBookTitleGradientTag];
        CAGradientLayer *gradient = (CAGradientLayer *)[gradientView layer];
        gradient.colors = [NSArray arrayWithObjects:
                           (id)[[UIColor colorWithWhite:1 alpha:0] CGColor],
                           (id)[[UIColor colorWithRed:0.969 green:0.969 blue:0.969 alpha:1.] CGColor],
                           nil];
        gradient.locations = [NSArray arrayWithObjects:
                              [NSNumber numberWithFloat:0.0f],
                              [NSNumber numberWithFloat:1.0f],
                              nil];
        gradient.startPoint = CGPointMake(0.0f, 0.5f);
        gradient.endPoint = CGPointMake(1.0f, 0.5f);

        self.selectionStyle = UITableViewCellSelectionStyleNone;
}
    return self;
}

- (void)prepareForReuse
{
    self.onCheckboxUpdate = nil;
    [super prepareForReuse];
}

- (UILabel *)bookTitleLabel
{
    return (UILabel *)[self viewWithTag:kBookTitleLabelTag];
}

- (SCHCheckbox *)enabledForUpdateCheckbox
{
    return (SCHCheckbox *)[self viewWithTag:kEnableForUpdateCheckboxTag];
}

- (void)enableSpinner:(BOOL)enable
{
    UIActivityIndicatorView *spinner = (UIActivityIndicatorView *)[self viewWithTag:kSpinnerTag];
    if (enable) {
        [spinner startAnimating];
    } else {
        [spinner stopAnimating];
    }
}

- (void)checkboxUpdated:(SCHCheckbox *)sender
{
    if (self.onCheckboxUpdate) {
        self.onCheckboxUpdate(sender.selected);
    }
}

@end
