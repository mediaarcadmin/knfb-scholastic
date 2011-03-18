//
//  SCHAppDictionaryState.h
//  Scholastic
//
//  Created by John S. Eddie on 18/03/2011.
//  Copyright (c) 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SCHAppDictionaryState : NSManagedObject {
@private
}
@property (nonatomic, retain) NSDate * LastModified;
@property (nonatomic, retain) NSNumber * State;
@property (nonatomic, retain) NSString * Version;

@end
