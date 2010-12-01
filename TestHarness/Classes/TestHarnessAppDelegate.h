

#import <UIKit/UIKit.h>



@interface TestHarnessAppDelegate : NSObject <UIApplicationDelegate>
{
    UIWindow *               window;
    UINavigationController * navigationController;
}

@property (nonatomic, retain) IBOutlet UIWindow *               window;
@property (nonatomic, retain) IBOutlet UINavigationController * navigationController;


@end

