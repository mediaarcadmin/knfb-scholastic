//
//  SCHStoryInteractionDraggableLetterView.m
//  Scholastic
//
//  Created by Neil Gall on 09/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionDraggableLetterView.h"

@interface SCHStoryInteractionDraggableLetterView ()
@end

@implementation SCHStoryInteractionDraggableLetterView

@synthesize letter;

- (id)initWithLetter:(unichar)aLetter
{
    const BOOL iPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    UIImage *bgImage = [UIImage imageNamed:iPad ? @"storyinteraction-lettertile-ipad" : @"storyinteraction-lettertile-iphone"];
    
    if ((self = [super initWithFrame:CGRectMake(0, 0, bgImage.size.width, bgImage.size.height)])) {
        UIImageView *iv = [[UIImageView alloc] initWithImage:bgImage];
        iv.frame = self.bounds;
        [self addSubview:iv];
        [iv release];
        UILabel *label = [[UILabel alloc] initWithFrame:self.bounds];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = UITextAlignmentCenter;
        label.text = [NSString stringWithCharacters:&aLetter length:1];
        label.font = [UIFont boldSystemFontOfSize:20];
        [self addSubview:label];
        [label release];
        
        letter = aLetter;
    }
    return self;
}

@end
