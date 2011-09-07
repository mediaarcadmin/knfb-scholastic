//
//  SCHKIFTestController.m
//  Scholastic
//
//  Created by John S. Eddie on 01/09/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHKIFTestController.h"

#import "KIFTestScenario+EXAdditions.h"

@interface SCHKIFTestController ()

- (void)initializeScenariosForiPhone;
- (void)initializeScenariosForiPad;

@end

@implementation SCHKIFTestController

- (void)initializeScenarios
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self initializeScenariosForiPad];
    } else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self initializeScenariosForiPad];        
    }
}

- (void)initializeScenariosForiPhone
{
    [self addScenario:[KIFTestScenario scenarioToLogin]];
    [self addScenario:[KIFTestScenario scenarioToDeregister]];    
}

- (void)initializeScenariosForiPad
{
    [self addScenario:[KIFTestScenario scenarioToLogin]];
    [self addScenario:[KIFTestScenario scenarioToDeregister]];    
}

@end