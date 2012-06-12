//
//  RateView.h
//  CustomView
//
//  Based on RateView by Ray Wenderlich
//

#import <UIKit/UIKit.h>

@class RateView;

@protocol RateViewDelegate
- (void)rateView:(RateView *)rateView ratingDidChange:(float)rating;
@end

@interface RateView : UIView

@property (retain, nonatomic) UIImage *notSelectedImage;
@property (retain, nonatomic) UIImage *halfSelectedImage;
@property (retain, nonatomic) UIImage *fullSelectedImage;
@property (assign, nonatomic) float rating;
@property (assign, nonatomic) BOOL preventUnrating;
@property (assign) BOOL editable;
@property (retain) NSMutableArray * imageViews;
@property (assign, nonatomic) int maxRating;
@property (assign) int midMargin;
@property (assign) int leftMargin;
@property (assign) CGSize minImageSize;
@property (assign) id <RateViewDelegate> delegate;
@property (assign, nonatomic) BOOL dimEmptyRatings; // default yes

@end
