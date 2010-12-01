//


#import "TestHarnessAppDelegate.h"

@implementation TestHarnessAppDelegate

@synthesize window;
@synthesize navigationController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    
    // Override point for customization after app launch    
	
	[window addSubview:[navigationController view]];
    [window makeKeyAndVisible];
	return YES;
}

- (void)dealloc
{
    [navigationController release];
    [window release];
    [super dealloc];
}

@end


