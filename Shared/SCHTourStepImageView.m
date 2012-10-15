//
//  SCHTourStepImageView.m
//  Scholastic
//
//  Created by Gordon Christie on 01/10/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHTourStepImageView.h"

@interface SCHTourStepImageView ()

@property (nonatomic, retain) UIImageView *tourImageView;

@end

@implementation SCHTourStepImageView

@synthesize tourImageView;

- (void)dealloc
{
    [tourImageView release], tourImageView = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame bottomBarVisible:(BOOL)bottomBarVisible
{
    self = [super initWithFrame:frame bottomBarVisible:bottomBarVisible];
    if (self) {
        // Initialization code
        
        self.tourImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)] autorelease];
        self.tourImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.tourImageView.contentMode = UIViewContentModeCenter;
        self.tourImageView.clipsToBounds = YES;
        
        [self.contentView addSubview:self.tourImageView];
    }
    return self;
}

- (void)setTourImage:(UIImage *)tourImage
{
    if (self.tourImageView) {
        self.tourImageView.image = tourImage;
        [self.contentView bringSubviewToFront:self.tourImageView];
    }
}

- (UIImage *)tourImage
{
    if (!self.tourImageView) {
        return nil;
    }
    
    return self.tourImageView.image;
}

@end
