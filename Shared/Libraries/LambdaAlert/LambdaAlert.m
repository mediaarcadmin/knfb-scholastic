#import "LambdaAlert.h"

@interface LambdaAlert () <UIAlertViewDelegate>
@property(retain) UIAlertView *alert;
@property(retain) NSMutableArray *blocks;
@property(nonatomic, retain) UIActivityIndicatorView *spinner;
@end

@implementation LambdaAlert
@synthesize alert, blocks;
@synthesize spinner;

- (id) initWithTitle: (NSString*) title message: (NSString*) message
{
    self = [super init];
    alert = [[UIAlertView alloc] initWithTitle:title message:message
        delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
    blocks = [[NSMutableArray alloc] init];
    return self;
}

- (void) dealloc
{
    [alert release];
    [blocks release];
    [spinner release];
    [super dealloc];
}

- (void) show
{
    [alert show];
    [self retain];
}

- (void) addButtonWithTitle: (NSString*) title block: (dispatch_block_t) block
{
    if (!block) block = ^{};
    [alert addButtonWithTitle:title];
    [blocks addObject:[[block copy] autorelease]];
}

- (void) alertView: (UIAlertView*) alertView didDismissWithButtonIndex: (NSInteger) buttonIndex
{
    if (buttonIndex >= 0 && buttonIndex < [blocks count]) {
        dispatch_block_t block = [blocks objectAtIndex:buttonIndex];
        block();
    }
    [self release];
}

- (void)dismissAnimated:(BOOL)animated
{
    [alert dismissWithClickedButtonIndex:-1 animated:animated];
}

- (UIActivityIndicatorView *)spinner
{
    if (!spinner) {
        spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [alert addSubview:spinner];
        [spinner setCenter:CGPointMake(CGRectGetMidX(alert.frame), CGRectGetMidY(alert.frame))];
        [spinner setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin];
    }
    
    return spinner;
}

- (void)setSpinnerHidden:(BOOL)hidden
{
    if (hidden) {
        [self.spinner stopAnimating];
    } else {
        [self.spinner startAnimating];
    }
}

@end
