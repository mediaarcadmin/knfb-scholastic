//
//  SCHKIFTestController.m
//  Scholastic
//
//  Created by John S. Eddie on 01/09/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHKIFTestController.h"

#import "KIFTestScenario+EXAdditions.h"

@implementation SCHKIFTestController

- (void)initializeScenarios
{
    [self addScenario:[KIFTestScenario scenarioToLogin]];
    // Add additional scenarios you want to test here
}

@end