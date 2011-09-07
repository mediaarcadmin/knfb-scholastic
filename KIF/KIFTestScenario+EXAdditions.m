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
    
    [scenario addStepsFromArray:[KIFTestStep stepsToLogin]];

    [scenario addStep:[KIFTestStep stepToWaitForViewWithAccessibilityLabel:@"Dictionary Download View"]];
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Close Button"]];    

    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Settings Button"]];
    
    
    return(scenario);
}

+ (id)scenarioToDeregister
{
    KIFTestScenario *scenario = [KIFTestScenario scenarioWithDescription:@"Test that a user can successfully deregister."];    

    [scenario addStepsFromArray:[KIFTestStep stepsToGoToDeregistrationPage]];
    
    return(scenario);
}

@end
