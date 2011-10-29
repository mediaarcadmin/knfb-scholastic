//
//  SCHSampleBooksManager.h
//  Scholastic
//
//  Created by Matt Farrugia on 24/10/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kSCHSampleBooksRemoteManifestURL;
extern NSString * const kSCHSampleBooksLocalManifestFile;

typedef void (^SCHSampleBooksProcessingSuccessBlock)(void);
typedef void (^SCHSampleBooksProcessingFailureBlock)(NSString * failureReason);

@protocol SCHSampleBooksImporterDelegate <NSObject>

- (void)importFailedWithReason:(NSString *)reason;

@end

@interface SCHSampleBooksImporter : NSObject <SCHSampleBooksImporterDelegate> {
    
}

- (void)importSampleBooksFromRemoteManifest:(NSURL *)remote 
                              localManifest:(NSURL *)local 
                               successBlock:(SCHSampleBooksProcessingSuccessBlock)successBlock
                               failureBlock:(SCHSampleBooksProcessingFailureBlock)failureBlock;
- (void)cancel;

+ (SCHSampleBooksImporter *)sharedImporter;

@end
