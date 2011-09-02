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

+ (NSArray *)stepsToGoToLoginPage;
{
    NSMutableArray *steps = [NSMutableArray array];
    
    [steps addObject:[KIFTestStep stepToTapRowInTableViewWithAccessibilityLabel:@"Starting Tableview" atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]];
    
    // Dismiss the welcome message
//    [steps addObject:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"That's awesome!"]];
    
    // Tap the "I already have an account" button
//    [steps addObject:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"I already have an account."]];
    
    return steps;
}

@end