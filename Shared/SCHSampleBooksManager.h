//
//  SCHSampleBooksManager.h
//  Scholastic
//
//  Created by Matt Farrugia on 24/10/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kSCHSampleBooksManifestURL;

typedef void (^SCHSampleBooksProcessingFailureBlock)(NSString * failureReason);

@protocol SCHSampleBooksProcessingDelegate <NSObject>

- (void)setCompletedWithSuccess:(BOOL)success failureReason:(NSString *)reason;

@end

@interface SCHSampleBooksManager : NSObject <SCHSampleBooksProcessingDelegate> {
    
}

@property (nonatomic, retain) NSManagedObjectContext *mainThreadManagedObjectContext;
@property (nonatomic, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)updateSampleBooksFromManifestURL:(NSURL *)url failureBlock:(SCHSampleBooksProcessingFailureBlock)failureBlock;
- (void)cancel;

+ (SCHSampleBooksManager *)sharedManager;

@end
