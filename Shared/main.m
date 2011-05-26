//
//  main.m
//  Scholastic
//
//  Created by John S. Eddie on 30/12/2010.
//  Copyright 2010 BitWink Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <libEucalyptus/THLog.h>

int main(int argc, char *argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];    
    sranddev();
    THProcessLoggingDefaults();
    [pool release];

    pool = [[NSAutoreleasePool alloc] init];    
    int retVal = UIApplicationMain(argc, argv, nil, nil);
    [pool release];
    return retVal;
}
