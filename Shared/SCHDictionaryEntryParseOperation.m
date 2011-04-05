//
//  SCHDictionaryEntryParseOperation.m
//  Scholastic
//
//  Created by Gordon Christie on 05/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHDictionaryEntryParseOperation.h"
#import "SCHDictionaryManager.h"

@interface SCHDictionaryEntryParseOperation ()

- (void)parseEntryTable;

@property BOOL executing;
@property BOOL finished;

@end

@implementation SCHDictionaryEntryParseOperation

@synthesize executing, finished;

- (void) start
{
    NSLog(@"Starting parse op.");
	if (![self isCancelled]) {
		
		NSLog(@"Starting parse operation..");
        
        SCHDictionaryManager *dictManager = [SCHDictionaryManager sharedDictionaryManager];
        
		dictManager.isProcessing = YES;
		
        [self willChangeValueForKey:@"isExecuting"];
        [self willChangeValueForKey:@"isFinished"];
        
        self.executing = YES;
        self.finished = NO;
        
        [self didChangeValueForKey:@"isExecuting"];
        [self didChangeValueForKey:@"isFinished"];        
        
        [self parseEntryTable];
        
        
        [[SCHDictionaryManager sharedDictionaryManager] threadSafeUpdateDictionaryState:SCHDictionaryProcessingStateDone];
        dictManager.isProcessing = NO;

        [self willChangeValueForKey:@"isExecuting"];
        [self willChangeValueForKey:@"isFinished"];
        
        self.executing = NO;
        self.finished = YES;
        
        [self didChangeValueForKey:@"isExecuting"];
        [self didChangeValueForKey:@"isFinished"];	
    }
}

- (void)parseEntryTable
{
    NSLog(@"Parsing entry table...");
    SCHDictionaryManager *dictManager = [SCHDictionaryManager sharedDictionaryManager];
    
    NSString *filePath = [[dictManager dictionaryDirectory] stringByAppendingPathComponent:@"EntryTable.txt"];
    
    FILE *file = fopen([filePath cStringUsingEncoding:NSUTF8StringEncoding], "r");
    char line[6560];
    
    long currentOffset = 0;
    
    NSLog(@"start");
    while (fgets(line, 6560, file) != NULL) {
        
        
        
        currentOffset = ftell(file);
        
        char *start, *entryID, *headword, *level;
        char *sep = "\t";
        
        start = strtok(line, sep);
        if (start != NULL) {
            entryID = strtok(NULL, sep);                    // MATCH
            if (entryID != NULL) {
                headword = strtok(NULL, sep);
                if (headword != NULL) {
                    level = strtok(NULL, sep);              // MATCH YD/OD
                }
            }
        }

        NSLog(@"Word: %@ Line offset: %ld", [NSString stringWithCString:headword encoding:NSUTF8StringEncoding], currentOffset);
        
    };
    NSLog(@"stop");
    fclose(file);
}

- (BOOL)isConcurrent {
	return YES;
}

- (BOOL)isExecuting {
	return self.executing;
}

- (BOOL)isFinished {
	return self.finished;
}

@end
