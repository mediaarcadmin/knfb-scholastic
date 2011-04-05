//
//  SCHDictionaryEntryParseOperation.m
//  Scholastic
//
//  Created by Gordon Christie on 05/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHDictionaryEntryParseOperation.h"
#import "SCHDictionaryManager.h"
#import "SCHBookManager.h"
#import "SCHDictionaryEntry.h"
#import "SCHDictionaryWordForm.h"


@interface SCHDictionaryEntryParseOperation ()

- (void)parseEntryTable;
- (void)parseWordFormTable;

@property BOOL executing;
@property BOOL finished;

@end

@implementation SCHDictionaryEntryParseOperation

@synthesize executing, finished;

- (void) start
{
	if (![self isCancelled]) {
		
        SCHDictionaryManager *dictManager = [SCHDictionaryManager sharedDictionaryManager];
        
		dictManager.isProcessing = YES;
		
        [self willChangeValueForKey:@"isExecuting"];
        [self willChangeValueForKey:@"isFinished"];
        
        self.executing = YES;
        self.finished = NO;
        
        [self didChangeValueForKey:@"isExecuting"];
        [self didChangeValueForKey:@"isFinished"];        
        
        [self parseEntryTable];
        [self parseWordFormTable];
        
        
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
    NSManagedObjectContext *context = [[SCHBookManager sharedBookManager] managedObjectContextForCurrentThread];
    
    NSString *filePath = [[dictManager dictionaryDirectory] stringByAppendingPathComponent:@"EntryTable.txt"];
    
    FILE *file = fopen([filePath cStringUsingEncoding:NSUTF8StringEncoding], "r");
    char line[6560];
    
    long currentOffset = 0;
    
    int savedItems = 0;
    
    while (fgets(line, 6560, file) != NULL) {
        
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

//        NSLog(@"Word: %@ Line offset: %ld", [NSString stringWithCString:headword encoding:NSUTF8StringEncoding], currentOffset);
		SCHDictionaryEntry *entry = [NSEntityDescription insertNewObjectForEntityForName:kSCHDictionaryEntry inManagedObjectContext:context];
        entry.word = [NSString stringWithCString:headword encoding:NSUTF8StringEncoding];
        entry.baseWordID = [NSString stringWithCString:entryID encoding:NSUTF8StringEncoding];
        entry.fileOffset = [NSNumber numberWithLong:currentOffset];
        entry.category = [NSString stringWithCString:level encoding:NSUTF8StringEncoding];
        
        savedItems++;
        
        currentOffset = ftell(file);
    };
    
    fclose(file);
    
    NSError *error = nil;
    
    [context save:&error];
    
    if (error)
    {
        NSLog(@"Error: could not save word entries. %@", [error localizedDescription]);
    } else {
        NSLog(@"Added %d entries to base words.", savedItems);
    }
}

- (void)parseWordFormTable
{
    NSLog(@"Parsing word form table...");
    SCHDictionaryManager *dictManager = [SCHDictionaryManager sharedDictionaryManager];
    NSManagedObjectContext *context = [[SCHBookManager sharedBookManager] managedObjectContextForCurrentThread];

    NSString *filePath = [[dictManager dictionaryDirectory] stringByAppendingPathComponent:@"WordFormTable.txt"];

    FILE *file = fopen([filePath cStringUsingEncoding:NSUTF8StringEncoding], "r");
    setlinebuf(file);
    char line[90];

    int savedItems = 0;

    while (fgets(line, 90, file) != NULL) {
        char *start, *wordform, *headword, *entryID, *category;
        char *sep = "\t";
        
        start = strtok(line, sep);
        if (start != NULL) {
            wordform = strtok(NULL, sep);                   // search
            if (wordform != NULL) {
                headword = strtok(NULL, sep);
                if (headword != NULL) {
                    entryID = strtok(NULL, sep);            // MATCH
                    if (entryID != NULL) {
                        category = strtok(NULL, sep);      // MATCH YD/OD/ALL
                    }
                }
            }
        }
        
		SCHDictionaryWordForm *form = [NSEntityDescription insertNewObjectForEntityForName:kSCHDictionaryWordForm inManagedObjectContext:context];
        form.word = [NSString stringWithCString:wordform encoding:NSUTF8StringEncoding];
        form.rootWord = [NSString stringWithCString:headword encoding:NSUTF8StringEncoding];
        form.baseWordID = [NSString stringWithCString:entryID encoding:NSUTF8StringEncoding];
        form.category = [NSString stringWithCString:category encoding:NSUTF8StringEncoding];
        
        savedItems++;
        
    };    

    fclose(file);
    
    NSError *error = nil;
    
    [context save:&error];
    
    if (error)
    {
        NSLog(@"Error: could not save word entries. %@", [error localizedDescription]);
    } else {
        NSLog(@"Added %d entries to word entries.", savedItems);
    }

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
