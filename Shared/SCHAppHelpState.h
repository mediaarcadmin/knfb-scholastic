//
//  SCHAppHelpState.h
//  Scholastic
//
//  Created by Matt Farrugia on 04/12/2011.
//  Copyright (c) 2011 BitWink. All rights reserved.
//

#import <CoreData/CoreData.h>

// Constants
extern NSString * const kSCHAppHelpState;

@interface SCHAppHelpState : NSManagedObject {
    
}

@property (nonatomic, retain) NSDate * LastModified;
@property (nonatomic, retain) NSNumber * State;
@property (nonatomic, retain) NSString * Version;
@property (nonatomic, retain) NSString * helpVideoVersion;
@property (nonatomic, retain) NSString * helpVideoOlderURL;
@property (nonatomic, retain) NSString * helpVideoYoungerURL;

@end
