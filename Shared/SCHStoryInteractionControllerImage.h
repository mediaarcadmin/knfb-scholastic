//
//  SCHStoryInteractionControllerImage.h
//  Scholastic
//
//  Created by John S. Eddie on 08/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SCHStoryInteractionController.h"

@interface SCHStoryInteractionControllerImage : SCHStoryInteractionController <UIScrollViewDelegate>
{    
}

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;

@end
