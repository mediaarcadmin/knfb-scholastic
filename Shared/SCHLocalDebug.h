//
//  SCHLocalDebug.h
//  Scholastic
//
//  Created by John S. Eddie on 13/01/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SCHLocalDebug : NSObject {
	
}

@property (retain, nonatomic) NSManagedObjectContext *managedObjectContext;	

- (void)setup;
- (void)setupLocalDataWithXPSFiles:(NSArray *)XPSFiles;

@end
