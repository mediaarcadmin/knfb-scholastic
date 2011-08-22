//
//  SCHReadingViewNavigationToolbar.m
//  Scholastic
//
//  Created by Matt Farrugia on 22/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHReadingViewNavigationToolbar.h"
#import "SCHCustomToolbar.h"

@interface SCHReadingViewNavigationToolbar()

+ (CGSize)sizeForStyle:(SCHReadingViewNavigationToolbarStyle)style orientation:(UIInterfaceOrientation)orientation;

@property (nonatomic, retain) UIImageView *shadowView;
@property (nonatomic, retain) UIImageView *backgroundView;
@property (nonatomic, retain) SCHCustomToolbar *toolbar;

@end

@implementation SCHReadingViewNavigationToolbar

@synthesize shadowView;
@synthesize backgroundView;
@synthesize toolbar;

- (id)initWithStyle:(SCHReadingViewNavigationToolbarStyle)style orientation:(UIInterfaceOrientation)orientation
{
    CGRect bounds = CGRectZero;
    bounds.size = [SCHReadingViewNavigationToolbar sizeForStyle:style orientation:orientation];
    
    self = [super initWithFrame:bounds];
    if (self) {
        // Initialization code
        
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc
{
    [super dealloc];
}

+ (CGSize)sizeForStyle:(SCHReadingViewNavigationToolbarStyle)style orientation:(UIInterfaceOrientation)orientation
{
    
    CGSize size = CGSizeZero;

    if (UIInterfaceOrientationIsPortrait(orientation)) {
        switch (style) {
            case kSCHReadingViewNavigationToolbarStyleYoungerPhone:
                size = CGSizeMake(320, 44);
                break;
            case kSCHReadingViewNavigationToolbarStyleOlderPhone:
                size = CGSizeMake(320, 33);
                break;
            case kSCHReadingViewNavigationToolbarStyleYoungerPad:
                size = CGSizeMake(320, 60);
                break;
            case kSCHReadingViewNavigationToolbarStyleOlderPad:
                size = CGSizeMake(320, 44);
                break;
        }
    } else {
        switch (style) {
            case kSCHReadingViewNavigationToolbarStyleYoungerPhone:
                size = CGSizeMake(320, 60);
                break;
            case kSCHReadingViewNavigationToolbarStyleOlderPhone:
                size = CGSizeMake(320, 44);
                break;
            case kSCHReadingViewNavigationToolbarStyleYoungerPad:
                size = CGSizeMake(320, 60);
                break;
            case kSCHReadingViewNavigationToolbarStyleOlderPad:
                size = CGSizeMake(320, 44);
                break;
        }
    }
    
    return size;
}

@end
