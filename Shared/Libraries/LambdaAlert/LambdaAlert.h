@interface LambdaAlert : NSObject {}

- (id) initWithTitle: (NSString*) title message: (NSString*) message;
- (void) addButtonWithTitle: (NSString*) title block: (dispatch_block_t) block;
- (void) show;

- (void)setSpinnerHidden:(BOOL)hidden;
- (void)dismissAnimated:(BOOL)animated;

@end
