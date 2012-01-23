#import "LambdaAlert.h"

@interface LambdaAlert () <UIAlertViewDelegate>
@property(retain) UIAlertView *alert;
@property(retain) NSMutableArray *blocks;
@property(nonatomic, retain) UIActivityIndicatorView *spinner;

- (void)positionSpinner;

@end

static const CGFloat kLambdaAlertSpinnerInsetPerButton = 44;

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
    [self positionSpinner];
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
        [spinner setCenter:CGPointMake(CGRectGetMidX(self.alert.frame), CGRectGetMidY(self.alert.frame))];
        [spinner setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin];
        [self.alert addSubview:spinner];
    }
    
    return spinner;
}

- (void)positionSpinner
{
    if (spinner) {
        CGFloat offsetY = floorf((CGRectGetHeight(self.alert.frame) - self.alert.numberOfButtons*kLambdaAlertSpinnerInsetPerButton)/2.0f);
        [spinner setCenter:CGPointMake(spinner.center.x, offsetY)];
    }
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
