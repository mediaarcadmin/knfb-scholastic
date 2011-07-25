//
//  SCHAppDictionaryState.h
//  Scholastic
//
//  Created by John S. Eddie on 18/03/2011.
//  Copyright (c) 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

// Constants
extern NSString * const kSCHAppDictionaryState;

@interface SCHAppDictionaryState : NSManagedObject {

}

@property (nonatomic, retain) NSDate * LastModified;
@property (nonatomic, retain) NSNumber * State;
@property (nonatomic, retain) NSString * Version;
@property (nonatomic, retain) NSNumber * InitialDictionaryProcessed;

@end
