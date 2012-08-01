//
//  SCHAppModelTests.m
//  Scholastic
//
//  Created by Matt Farrugia on 01/08/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <OCMock.h>
#import "SCHAppModelTests.h"
#import "SCHAppModel.h"
#import "SCHAppController.h"
#import "SCHSampleBooksImporter.h"
#import "SCHAuthenticationManager.h"
#import "SCHSyncManager.h"
#import "SCHProfileSyncComponent.h"

@interface SCHAppModelTests()

@property (nonatomic, retain) SCHAppModel *appModel;
@property (nonatomic, retain) OCMockObject<SCHAppController> *appController;

@end

@implementation SCHAppModelTests

@synthesize appModel;
@synthesize appController;

- (void)dealloc
{
    [appModel release], appModel = nil;
    [appController release], appController = nil;
    [super dealloc];
}

- (void)setUp
{
    self.appController = [OCMockObject mockForProtocol:@protocol(SCHAppController)];
    self.appModel = [[[SCHAppModel alloc] initWithAppController:self.appController] autorelease];
}

- (void)tearDown
{
    self.appModel = nil;
    self.appController = nil;
}

#pragma mark - Preview Tests

- (void)testPreviewPresented 
{
    id mockImporter = [self mockSampleImporterWithSuccess:YES];
    
    [[self.appController expect] presentSamplesWithWelcome:YES];
    [self.appModel setupPreviewWithImporter:mockImporter];
    
    [mockImporter verify];
    [self.appController verify];
}

- (void)testPreviewFailed 
{
    id mockImporter = [self mockSampleImporterWithSuccess:NO];

    [[self.appController expect] failedSamplesWithError:[OCMArg any]];
    [self.appModel setupPreviewWithImporter:mockImporter];
    
    [mockImporter verify];
    [self.appController verify];
}

#pragma mark - Login Tests

- (void)testProfilesPresentedAfterLogin
{
    id mockSyncManager = [self mockSyncManagerWithSuccess:YES];
    id mockAuthManager = [self mockAuthenticationManagerWithSuccess:YES];
    id mockAppModel = [OCMockObject partialMockForObject:self.appModel];
    
    [[self.appController expect] presentProfiles];
    [[[mockAppModel expect] andReturnValue:[NSNumber numberWithBool:YES]] hasProfilesInManagedObjectContext:[OCMArg any]];
    
    [mockAppModel loginWithUsername:@"user@scholastic.com" 
                            password:@"pass" 
                         syncManager:mockSyncManager
               authenticationManager:mockAuthManager];
    
    [mockSyncManager verify];
    [mockAuthManager verify];
    [self.appController verify];
}

- (void)testProfilesSetupPresentedAfterLogin
{
    id mockSyncManager = [self mockSyncManagerWithSuccess:YES];
    id mockAuthManager = [self mockAuthenticationManagerWithSuccess:YES];
    id mockAppModel = [OCMockObject partialMockForObject:self.appModel];
    
    [[self.appController expect] presentProfiles];
    [[[mockAppModel expect] andReturnValue:[NSNumber numberWithBool:YES]] hasProfilesInManagedObjectContext:[OCMArg any]];
    
    [mockAppModel loginWithUsername:@"user@scholastic.com" 
                           password:@"pass" 
                        syncManager:mockSyncManager
              authenticationManager:mockAuthManager];
    
    [mockSyncManager verify];
    [mockAuthManager verify];
    [self.appController verify];
}

#pragma mark - Helper methods

- (id)mockAuthenticationManagerWithSuccess:(BOOL)success
{
    id mockAuthManager = [OCMockObject mockForClass:[SCHAuthenticationManager class]];
    
    [[[mockAuthManager expect] andDo:^(NSInvocation *invocation) {
        if (success) {
            SCHAuthenticationSuccessBlock successBlock;
            [invocation getArgument:&successBlock atIndex:4];
            successBlock(SCHAuthenticationManagerConnectivityModeOnline);
        } else {
            SCHAuthenticationFailureBlock failureBlock;
            [invocation getArgument:&failureBlock atIndex:5];
            failureBlock(nil);
        }
    }] authenticateWithUser:[OCMArg any] 
     password:[OCMArg any] 
     successBlock:[OCMArg any] 
     failureBlock:[OCMArg any]
     waitUntilVersionCheckIsDone:YES];
    
    return mockAuthManager;
}

- (id)mockSyncManagerWithSuccess:(BOOL)success
{
    id mockSyncManager = [OCMockObject mockForClass:[SCHSyncManager class]];

    NSNotification *notification;
    if (success) {
        notification = [NSNotification notificationWithName:SCHProfileSyncComponentDidCompleteNotification object:mockSyncManager userInfo:nil];
    } else {
        notification = [NSNotification notificationWithName:SCHProfileSyncComponentDidFailNotification object:mockSyncManager userInfo:nil];
    }
    
    [[[mockSyncManager expect] andPost:notification] firstSync:YES requireDeviceAuthentication:NO];
    [[mockSyncManager expect] resetSync];
    
    return mockSyncManager;
}

- (id)mockSampleImporterWithSuccess:(BOOL)success
{
    id mockImporter = [OCMockObject mockForClass:[SCHSampleBooksImporter class]];
    
    [[[mockImporter expect] andDo:^(NSInvocation *invocation) {
        if (success) {
            SCHSampleBooksProcessingSuccessBlock successBlock;
            [invocation getArgument:&successBlock atIndex:4];
            successBlock();
        } else {
            SCHSampleBooksProcessingFailureBlock failureBlock;
            [invocation getArgument:&failureBlock atIndex:5];
            failureBlock(@"Failure reason");
        }
    }] importSampleBooksFromRemoteManifest:[OCMArg any] 
     localManifest:[OCMArg any] 
     successBlock:[OCMArg any] 
     failureBlock:[OCMArg any]];
    
    return mockImporter;
}


@end