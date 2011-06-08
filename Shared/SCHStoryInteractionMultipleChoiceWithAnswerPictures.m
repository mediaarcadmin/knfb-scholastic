//
//  SCHStoryInteractionMultipleChoiceWithAnswerPictures.m
//  Scholastic
//
//  Created by Neil Gall on 07/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionMultipleChoiceWithAnswerPictures.h"

#import "KNFBXPSConstants.h"

@implementation SCHStoryInteractionMultipleChoicePictureQuestion

- (NSString *)imagePathForAnswerAtIndex:(NSInteger)answerIndex
{
    NSString *filename = [NSString stringWithFormat:@"%@_q%da%d.png", self.storyInteraction.ID, self.questionIndex+1, answerIndex+1];
    return [KNFBXPSStoryInteractionsDirectory stringByAppendingPathComponent:filename];
}

@end

@implementation SCHStoryInteractionMultipleChoiceWithAnswerPictures
@end
