//
//  KIFTestScenario+EXAdditions.m
//  Scholastic
//
//  Created by John S. Eddie on 01/09/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "KIFTestScenario+EXAdditions.h"

#import "KIFTestStep.h"
#import "KIFTestStep+EXAdditions.h"

@implementation KIFTestScenario (EXAdditions)

+ (id)scenarioToLogin;
{
    KIFTestScenario *scenario = [KIFTestScenario scenarioWithDescription:@"Test that a user can successfully log in."];
    
    [scenario addStep:[KIFTestStep stepToReset]];
    [scenario addStepsFromArray:[KIFTestStep stepsToGoToLoginPage]];
    [scenario addStep:[KIFTestStep stepToEnterText:@"qa_knfbp_mf" intoViewWithAccessibilityLabel:@"Login User Name"]];
    [scenario addStep:[KIFTestStep stepToEnterText:@"pass" intoViewWithAccessibilityLabel:@"Login Password"]];
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Login"]];
    
//    // Verify that the login succeeded
//    [scenario addStep:[KIFTestStep stepToWaitForTappableViewWithAccessibilityLabel:@"Welcome"]];
    
    return(scenario);
}

@end
