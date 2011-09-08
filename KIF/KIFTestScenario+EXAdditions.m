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

+ (id)scenarioToYoungerSampleShelf
{
    KIFTestScenario *scenario = [KIFTestScenario scenarioWithDescription:@"Test that a user can view the younger sample bookshelf."];

    [scenario addStep:[KIFTestStep stepToTapRowInTableViewWithAccessibilityLabel:@"Starting Tableview" atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]];
    
    [scenario addStep:[KIFTestStep stepToWaitForViewWithAccessibilityLabel:@"Dictionary Download View"]];
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Close Button"]];

    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Back To Bookshelves Button"]];
    
    return(scenario);    
}


+ (id)scenarioToOlderSampleShelf
{
    KIFTestScenario *scenario = [KIFTestScenario scenarioWithDescription:@"Test that a user can view the older sample bookshelf."];
    
    [scenario addStep:[KIFTestStep stepToTapRowInTableViewWithAccessibilityLabel:@"Starting Tableview" atIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]]];

    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Back To Bookshelves Button"]];

    return(scenario);    
}

+ (id)scenarioToLogin
{
    KIFTestScenario *scenario = [KIFTestScenario scenarioWithDescription:@"Test that a user can successfully log in."];
    
    [scenario addStep:[KIFTestStep stepToReset]];
    
    [scenario addStepsFromArray:[KIFTestStep stepsToLogin]];

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
