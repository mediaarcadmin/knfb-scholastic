//
//  SCHReadingView.h
//  Scholastic
//
//  Created by Matt Farrugia on 27/03/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SCHReadingView;

@protocol SCHReadingViewDelegate <NSObject>

@optional

- (void) readingView: (SCHReadingView *) readingView hasMovedToPage: (NSInteger) page;
- (void) unhandledTouchOnPageForReadingView: (SCHReadingView *) readingView;

@end

@interface SCHReadingView : UIView {
    
}

@property (nonatomic, retain) NSString *isbn;
@property (nonatomic, retain) id <SCHReadingViewDelegate> delegate;

- (id) initWithFrame:(CGRect)frame isbn:(id)isbn;
- (void) jumpToPage: (NSInteger) page animated: (BOOL) animated;

@end