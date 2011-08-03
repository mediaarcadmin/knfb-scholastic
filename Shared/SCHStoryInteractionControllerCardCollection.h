//
//  SCHStoryInteractionControllerCardCollection.h
//  Scholastic
//
//  Created by Neil Gall on 03/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionController.h"

@interface SCHStoryInteractionControllerCardCollection : SCHStoryInteractionController {}

@property (nonatomic, retain) IBOutletCollection(UIView) NSArray *cardViews;

@end
