//
//  SCHStoryInteractionControllerCardCollection.h
//  Scholastic
//
//  Created by Neil Gall on 03/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionController.h"

@interface SCHStoryInteractionControllerCardCollection : SCHStoryInteractionController <UIScrollViewDelegate> {}

@property (nonatomic, retain) IBOutletCollection(UIView) NSArray *cardViews;
@property (nonatomic, retain) IBOutletCollection(UIButton) NSArray *zoomedCardButtons;
@property (nonatomic, retain) IBOutlet UIView *perspectiveView;
@property (nonatomic, retain) IBOutlet UIScrollView *zoomedCardScrollView;
@property (nonatomic, retain) IBOutlet UIView *scrollContentView;

- (IBAction)flip:(id)sender;
- (IBAction)zoomOut:(id)sender;
- (IBAction)previousCard:(id)sender;
- (IBAction)nextCard:(id)sender;

@end
