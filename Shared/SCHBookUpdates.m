//
//  SCHBookUpdates.m
//  Scholastic
//
//  Created by Neil Gall on 26/07/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHBookUpdates.h"
#import "SCHAppBook.h"
#import "SCHBookIdentifier.h"
#import "SCHBookManager.h"
#import "SCHAppStateManager.h"
#import "SCHContentMetadataItem.h"

#define DEBUG_FORCE_ENABLE_UPDATES 0

@interface SCHBookUpdates ()
@property (nonatomic, assign) BOOL refreshNeeded;
@property (nonatomic, retain) NSMutableArray *results;

@end

@implementation SCHBookUpdates

@synthesize managedObjectContext;
@synthesize results;
@synthesize refreshNeeded;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [results release], results = nil;
    [super dealloc];
}

- (id)init
{
    self = [super init];
    
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(bookStateDidUpdate:)
                                                     name:@"SCHBookStateUpdate"
                                                   object:nil];

        self.results = [NSMutableArray array];
    }
    
    return self;
}

- (BOOL)areBookUpdatesAvailable
{
    return [[self availableBookUpdates] count] > 0;
}

- (NSArray *)availableBookUpdates
{
    if (self.refreshNeeded || [self.results count] == 0) {
        [self refresh];
    }
    
    if ([self.results count] == 0) {
        return nil;
    }
    return [NSArray arrayWithArray:results];
}

- (void)refresh
{
    NSError *error = nil;
    
    [self.results removeAllObjects];
    
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    [fetch setEntity:[NSEntityDescription entityForName:@"SCHAppBook" inManagedObjectContext:self.managedObjectContext]];
    [fetch setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"ContentMetadataItem.Title" ascending:YES]]];
    
    NSPredicate *statePred = [NSPredicate predicateWithFormat:@"State >= 0"];
    [fetch setPredicate:statePred];
    
    NSArray *allAppBooks = [self.managedObjectContext executeFetchRequest:fetch error:&error];
    
    [allAppBooks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SCHContentMetadataItem *contentMetadataItem = [obj ContentMetadataItem];
        
        if ([[contentMetadataItem Version] integerValue] != [[[contentMetadataItem UserContentItem] Version] integerValue]) {
            [self.results addObject:obj];
        }
    }];
    
    self.refreshNeeded = NO;
}

#pragma mark - book state updates

- (void)bookStateDidUpdate:(NSNotification *)note
{
    self.refreshNeeded = YES;
}

@end
