//
//  SCHStoryInteractionPageAssociation.h
//  Scholastic
//
//  Created by Neil Gall on 03/11/2011.
//  Copyright (c) 2011 BitWink. All rights reserved.
//

enum SCHStoryInteractionQuestionPageAssociation {
    SCHStoryInteractionQuestionOnLeftPage = 1 << 0,
    SCHStoryInteractionQuestionOnRightPage = 1 << 1,
    SCHStoryInteractionQuestionOnBothPages = (SCHStoryInteractionQuestionOnLeftPage | SCHStoryInteractionQuestionOnRightPage)
};

