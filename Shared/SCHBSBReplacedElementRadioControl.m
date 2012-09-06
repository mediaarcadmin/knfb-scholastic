//
//  SCHBSBReplacedElementRadioControl.m
//  Scholastic
//
//  Created by Matt Farrugia on 06/09/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHBSBReplacedElementRadioControl.h"

@interface SCHBSBReplacedElementRadioControl()

@property (nonatomic, retain) UIFont *font;
@property (nonatomic, retain) NSMutableArray *buttonArray;
@property (nonatomic, retain) NSMutableArray *labelArray;

@end;

@implementation SCHBSBReplacedElementRadioControl

@synthesize font;

- (void)dealloc
{
    [font release], font = nil;
    [super dealloc];
}
- (id)initWithItems:(NSArray *)items
{
    self = [super init];
    if (self) {
        // Initialization code
        font = [[UIFont systemFontOfSize:17] retain];
        
        for (int i = 0; i < [items count]; i++) {
            NSString *item = [items objectAtIndex:i];
            [self insertRadioItem:item atIndex:i];
        }
        
    }
    return self;
}

- (void)insertRadioItem:(NSString *)item atIndex:(NSUInteger)index
{
    if (index <= [self.buttonArray count]) {
        UIControl *button = [[UIControl alloc] init];
        [button addTarget:self action:@selector(radioButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
        [button addTarget:self action:@selector(radioButtonDepressed:) forControlEvents:UIControlEventTouchDown];
    }
}

- (NSUInteger)numberOfButtons
{
    return [self.buttonArray count];
}

- (NSInteger)selectedButtonIndex
{
    NSInteger ret = SCHBSBReplacedElementRadioControlNoButton;
    
    for (UIButton *button in self.buttonArray) {
        if ([button isSelected]) {
            ret = [self.buttonArray indexOfObject:button];
            break;
        }
    }
    
    return ret;
}

- (void)setSelectedButtonIndex:(NSInteger)selectedButtonIndex
{
    if (selectedButtonIndex < [self.buttonArray count]) {
        for (int i = 0; i < [self.buttonArray count]; i++) {
            UIButton *button = [self.buttonArray objectAtIndex:i];
            
            if (i == selectedButtonIndex) {
                if (![button isSelected]) {
                    [button setSelected:YES];
                }
            } else {
                if ([button isSelected]) {
                    [button setSelected:NO];
                }
            }
        }
    }
}

- (void)setTitle:(NSString *)title forButtonAtIndex:(NSUInteger)index
{
    if (index < [self.labelArray count]) {
        [[self.labelArray objectAtIndex:index] setText:title];
    }
}

- (NSString *)titleForButtonAtIndex:(NSUInteger)index
{
    NSString *ret = nil;
    
    if (index < [self.labelArray count]) {
        ret = [[self.labelArray objectAtIndex:index] text];
    }
    
    return ret;
}

- (void)setEnabled:(BOOL)enabled forButtonAtIndex:(NSUInteger)index
{
    if (index < [self.buttonArray count]) {
        [[self.buttonArray objectAtIndex:index] setEnabled:enabled];
    }
}

- (BOOL)isEnabledForButtonAtIndex:(NSUInteger)index
{
    BOOL ret = NO;
    
    if (index < [self.buttonArray count]) {
        ret = [[self.buttonArray objectAtIndex:index] isEnabled];
    }
    
    return ret;
}
      
#pragma mark - Button events

- (void)radioButtonSelected:(UIControl *)sender
{
    NSInteger index = [self.buttonArray indexOfObject:sender];
    [self setSelectedButtonIndex:index];
}

- (void)radioButtonDepressed:(UIControl *)sender
{
    NSLog(@"Depressed button!");
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
