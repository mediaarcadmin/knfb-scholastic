//
//  KIFTestStep+EXAdditions.h
//  Scholastic
//
//  Created by John S. Eddie on 01/09/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KIFTestStep.h"

@interface KIFTestStep (EXAdditions)

// Factory Steps

+ (id)stepToReset;

// Step Collections

// Assumes the application was reset and sitting at the welcome screen
+ (NSArray *)stepsToLogin;
+ (NSArray *)stepsToGoToDeregistrationPage;

@end
