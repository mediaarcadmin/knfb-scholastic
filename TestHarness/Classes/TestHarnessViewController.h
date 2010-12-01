

#import <UIKit/UIKit.h>
#include "XpsSdk.h"
@class TestHarnessAppDelegate;
@class TestRenderingView;

@interface TestHarnessViewController : UIViewController <UIScrollViewDelegate> {
    NSString *resourcePath;
    NSInteger maxPages;
    NSInteger currentPage;
    NSString *tmpPath;
    TestRenderingView *testView;
}

@property (nonatomic, retain) NSString * resourcePath;
@property (nonatomic, retain) NSString * tmpPath;
@property (nonatomic) NSInteger currentPage;
@property (nonatomic, retain) TestRenderingView *testView;

@end
