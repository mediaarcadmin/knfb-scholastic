//
//  SCHBSBReplacedTextElement.m
//  Scholastic
//
//  Created by Matt Farrugia on 21/08/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHBSBReplacedTextElement.h"
#import "SCHBSBReplacedElementTextField.h"
#import <libEucalyptus/EucUIViewViewSpiritElement.h>

@interface SCHBSBReplacedTextElement() <UITextFieldDelegate>

@property (nonatomic, retain) NSString *binding;
@property (nonatomic, retain) UIView *textView;

@end

@implementation SCHBSBReplacedTextElement

@synthesize binding;
@synthesize textView;

- (void)dealloc
{
    [binding release], binding = nil;
    [textView release], textView = nil;
    [super dealloc];
}

- (id)initWithPointSize:(CGFloat)point binding:(NSString *)textBinding
{
    if (self = [super initWithPointSize:point]) {
        binding = [textBinding copy];
    }
    
    return self;
}

- (CGSize)intrinsicSize
{
    return CGSizeMake(160, 10 + self.pointSize * 2);
}

- (THCGViewSpiritElement *)newViewSpiritElement
{
    if (self.textView) {
        return [[EucUIViewViewSpiritElement alloc] initWithView:self.textView];
    }
    
    return nil;
}

- (UIView *)textView
{
    if (!textView) {
        CGRect frame = CGRectZero;
        frame.size = self.intrinsicSize;
        
        SCHBSBReplacedElementTextField *textField = [[SCHBSBReplacedElementTextField alloc] initWithFrame:frame];
        textField.borderStyle = UITextBorderStyleRoundedRect;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.returnKeyType = UIReturnKeyDone;
        textField.delegate = self;
        
        [textField addTarget:textField action:@selector(endEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
        textView = textField;
    }
    
    return textView;
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    UIView *container = textField.superview.superview.superview;
    
    CGFloat textFieldY;
    CGFloat superviewY;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        textFieldY = CGRectGetMidY([container convertRect:textField.bounds fromView:textField]);
        superviewY = CGRectGetMidY(container.frame)/2.0f;
    } else {
        textFieldY = CGRectGetMaxY([container convertRect:textField.bounds fromView:textField]);
        superviewY = CGRectGetMidY(container.frame);
    }
    
    if (textFieldY > superviewY) {
        [UIView animateWithDuration:0.25f animations:^{
            [textField.superview.superview.superview setTransform:CGAffineTransformMakeTranslation(0, superviewY - textFieldY)];
        }];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    UIView *container = textField.superview.superview.superview;

    [UIView animateWithDuration:0.25f animations:^{
        [container setTransform:CGAffineTransformIdentity];
    }];
}

@end
