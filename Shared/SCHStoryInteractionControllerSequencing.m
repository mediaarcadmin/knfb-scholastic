//
//  SCHStoryInteractionControllerSequencing.m
//  Scholastic
//
//  Created by Neil Gall on 08/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionControllerSequencing.h"
#import "SCHStoryInteractionSequencing.h"
#import "SCHStoryInteractionDraggableView.h"

#define kNumberOfImages 3

@implementation SCHStoryInteractionControllerSequencing

@synthesize imageContainer1;
@synthesize imageContainer2;
@synthesize imageContainer3;
@synthesize imageView1;
@synthesize imageView2;
@synthesize imageView3;
@synthesize target1;
@synthesize target2;
@synthesize target3;

- (void)dealloc
{
    [imageContainer1 release];
    [imageContainer2 release];
    [imageContainer3 release];
    [imageView1 release];
    [imageView2 release];
    [imageView3 release];
    [target1 release];
    [target2 release];
    [target3 release];
    [super dealloc];
}

- (void)setupViewAtIndex:(NSInteger)screenIndex
{
    SCHStoryInteractionSequencing *sequencing = (SCHStoryInteractionSequencing *)self.storyInteraction;
    NSAssert([sequencing numberOfImages] == kNumberOfImages, @"controller/views designed for exactly 3 images!");
    
    NSMutableArray *containers = [NSMutableArray arrayWithObjects:self.imageContainer1, self.imageContainer2, self.imageContainer3, nil];
    NSMutableArray *imageViews = [NSMutableArray arrayWithObjects:self.imageView1, self.imageView2, self.imageView3, nil];
    NSArray *targets = [NSArray arrayWithObjects:self.target1, self.target2, self.target3, nil];
    
    for (NSInteger i = 0; i < kNumberOfImages; ++i) {
        UIImage *image = [self imageAtPath:[sequencing imagePathForIndex:i]];
        NSInteger pos = arc4random() % [imageViews count];
        SCHStoryInteractionDraggableView *container = [containers objectAtIndex:pos];
        [container setTag:i];
        [[imageViews objectAtIndex:pos] setImage:image];
        [[targets objectAtIndex:pos] setTag:i];
        [containers removeObjectAtIndex:pos];
        [imageViews removeObjectAtIndex:pos];
    }
}

@end
