//
//  KIFTestStep+EXAdditions.m
//  Scholastic
//
//  Created by John S. Eddie on 01/09/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "KIFTestStep+EXAdditions.h"


@implementation KIFTestStep (EXAdditions)

#pragma mark - Factory Steps

+ (id)stepToReset;
{
    return [KIFTestStep stepWithDescription:@"Reset the application state." executionBlock:^(KIFTestStep *step, NSError **error) {
        BOOL successfulReset = YES;
        
        // Do the actual reset for your app. Set successfulReset = NO if it fails.
        
        KIFTestCondition(successfulReset, error, @"Failed to reset some part of the application.");
        
        return KIFTestStepResultSuccess;
    }];
}

#pragma mark - Step Collections

+ (NSArray *)stepsToLogin
{
    NSMutableArray *steps = [NSMutableArray array];
    
    [steps addObject:[KIFTestStep stepToTapRowInTableViewWithAccessibilityLabel:@"Starting Tableview" atIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]]];
    
    [steps addObject:[KIFTestStep stepToWaitForViewWithAccessibilityLabel:@"Login View"]];
    
    [steps addObject:[KIFTestStep stepToEnterText:@"qa_knfbp_mf" intoViewWithAccessibilityLabel:@"Login User Name"]];
    [steps addObject:[KIFTestStep stepToEnterText:@"pass" intoViewWithAccessibilityLabel:@"Login Password"]];
    [steps addObject:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Login"]];
    
    return steps;
}

+ (NSArray *)stepsToGoToDeregistrationPage
{
    NSMutableArray *steps = [NSMutableArray array];
    
//    [steps addObject:[KIFTestStep stepToTapRowInTableViewWithAccessibilityLabel:@"Starting Tableview" atIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]]];
    
    return steps;    
}

@end